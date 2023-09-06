# OfferGenie

Magic deals tailored just for you with OfferGenie!

https://offergenie.fly.dev

## Setup

Clone the repo and run `bin/setup`.

If you use [direnv](https://direnv.net), you can inspect [.envrc](.envrc) then run `direnv allow`. This will add `bin` to your path so you can simply run `setup`, `rails`, or `dev` and actually be running the scripts in the `bin` directory. Neat. I'll write the rest of the instructions using the `bin/` prefix though.

If you run `rails db:seed` some data will be created for you. But before you do that, if you have access the ChatGPT API, add an OpenAI access token to your .envrc.local (or just .env and `source` it):

```sh
export OPENAI_ACCESS_TOKEN=...
```

Now running `rails db:seed` will use ChatGPT to generate much more interesting sample data. It may take a few minutes.

Start up the server with `bin/dev` and visit http://localhost:3000.

Check the linting with `bundle exec rubocop` and `yarn lint`.

Run the tests with `rails test`. You can view code coverage with `open coverage/index.html`.

Build the docs with `bundle exec yard` and see them with `open doc/index.html`.

## Code

I tried to write some high level information in the docs, so please read that too. This will be lower level information that I think is useful or interesting, and I'll try to walk through my though process on some things. I'll start with `OffersController`, which makes this call:

```ruby
Offer.available
     .unactivated_by(current_user)
     .recommended_for(current_user)
     .order(id: :desc)
```

That looks nice and clean, but here's the SQL it generates:

> `SELECT offers.*, ( word_similarity('furniture garden outdoor sale discount patio', keywords) + case when age_range = '35-39' and gender = 'male' then 10 else 0 end + case when offers.created_at > '2023-09-06 04:15:52.704194' then 10 else 0 end ) as recommendation_score FROM "offers" left outer join activations on activations.offer_id = offers.id and activations.user_id = 1 WHERE (number_available is null or (select count(activations.id) from activations where activations.offer_id = offers.id) < number_available) AND "activations"."id" IS NULL ORDER BY "recommendation_score" DESC, "offers"."id" DESC`

Breaking down the Ruby code, `available` is a scope that returns offers that are still available, taking into account offers that have a limited number of uses, `unactivated_by` is a scope that creates the left outer join that prevents offers from showing up that the user has already activated, and `recommended_for` is another scope that uses a recommendation algorithm to match offers to the user's age and gender based how other users in the same demographic rated those offers (which are correlated by matching up the keywords the offers have in common). The final `order(id: :desc)` is just to make the newest offers show first if all other things are equal.

I spent a good deal of time thinking about the recommendation system. The simplest solution would be to match up users and offers directly where users only see offers in their same age range and gender. But that puts the work of deciding which offers are the best fit for a user on the merchant who's placing the offer. I wanted to try to make it smarter. The merchant could choose keywords that apply to the offer, then I try to correlate the keywords and the demographics. Users in a demographic who interacted with one set of keywords might be likely to be interested in an offer that has a similar set of keywords. This is what the combination of the `Recommender` class and the Postgres GiST index/`word_similarity` is attempting to do.

First, `Recommender` takes score data from the `Activation` model (which represents when a user accepts or "activates" an offer) and the `Rating` model (which is intended to represent likes/dislikes or some other method of ranking keywords--I also made a way to have ChatGPT try to guess at these), and combines it into a data structure that looks like this:

```ruby
{"18-24 female"=>{"shoes"=>20, "bogo"=>20, "footwear"=>20, "heels"=>15},
 "30-34 male"=>{"adventure"=>10, "hiking"=>10, "gear"=>10, "discount"=>10},
 "90+ male"=>{"games"=>5, "bogo"=>5, "toys"=>5, "sandals"=>5}}
```

Next, the [`pearson`](https://github.com/alfonsojimenez/pearson) gem takes the values and uses them to recommend keywords from other demographics that might also interest the target demographic. So for example, because "18-24 female" and "90+ male" both have "bogo" as keywords with a good rating, users in one demographic might be interested in keywords from the other demographic. The list of keywords from the Pearson algorithm are sorted by score and the top ten are taken.

Next, the keywords that best represent the user's demographic are passed through Postgres' `word_similarity` function. This is usually used for full text search, but it does exactly what I need--finds records with the best similarity to the provided keywords. The nice thing is that this is done on trigrams, which allows for differences in spelling between the suggested keywords and the keywords used by the merchants. It provides a score, which is added together with a couple other factors:

```ruby
<<~SQL.squish
  (
    word_similarity(?, keywords) +
    case when age_range = ? and gender = ? then #{DEMOGRAPHIC_BOOST} else 0 end +
    case when offers.created_at > ? then #{NEW_BOOST} else 0 end
  ) as recommendation_score
SQL
```

This gives a boost to offers that _do_ have a specific age range and gender, plus a boost for offers that are new, pushing those to the top of the results and potentially getting more new keywords in front of people.

At this point it's just a matter of sorting the results by this calculated value. The end result is that the user sees the "best" offers first, but still has access to every offer, even if it's a better fit for a demographic they're not a part of.

I also wanted a way to play with this data beyong just putting things in manually or using Faker, so I created a little module for talking to ChatGPT:

```ruby
Simulate.create_offers!
Simulate.rate_keywords!
```

The first command creates offers, and it creates some pretty realistic data. Along with a title and description for each offer, I have ChatGPT create a list of keywords. The `rate_keywords!` method uses a random sample of those and a random sample of demographics, and asks ChatGPT to pick the best fit for each demographic. I translate those back into `Rating` records which influence the recommendations.

There are also Rake tasks:

```sh
rake simulate:create_offers
rake simulate:rate_keywords
rake simulate:rate_keywords_loop # Runs every 10 seconds
```

I wanted to have a way to see this data working, so if you're looking at the site, add `?debug=1` to the URL and offers will be displayed along with a JSON version of their attributes, which allows you to see the recommendation score as well as the keywords and other data.

Finally, I wanted to simulate having unique coupon codes generated for the user when they activate an offer. A merchant could use this to generate one time use codes in their shopping cart software, making sure users don't share the coupon codes with each other. To do this, each merchant has an option API URL and key, and each offer can have an "activation code" which would be sent to the merchant's API. The merchant would return the user's personalized coupon code, and that's what gets displayed to the user. I set this up to be optional though, so offers can simply have static coupon codes attached to them.
