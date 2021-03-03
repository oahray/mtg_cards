# MtgCards

This gem consumes the Cards enpoint of the ['Magic: The Gathering' API](https://magicthegathering.io/) and allows users get a list of cards based on command-line argument filters.

## Usage

To run, navigate to the project root folder and call the executable along with command line arguments. Run the command below to see a list commands avalalzble for the current version of this project

```
`$ bin/mtg_cards -h`
```

Alternatively, you could build and install this gem locally by running (from the project root)
```
$ gem build mtg_cards.gemspec
$ gem install mtg_cards-0.1.0.gem
```
or

```
$ bundle exec rake install
```

## Development and Testing

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Dev Approach

### Implemented features
This project was implemented with the Ruby standard library and no external dependencies (except rspec, our testing suite). With the current version of the project, users can
- get cards grouped by set.
- get cards grouped by set, with each set grouped further by rarity
- get red AND blue cards from the Khans of Tarkir (KTK) set.
- an attempt at concurrency with Ruby Fibers, as true parallelising is not technically possible with versions of Ruby earlier than the recent 3.0.0

### Initial Analysis
Initial analysis was 'fetch the data, process in to groups by set, and then by rarity'. One part I did not realise was that all the data spanned 500+ pages (until I read the documentation and checked the link session of the response headers). Still, at a glance, there were obvious bottlenecks:
- There was the likelyhood that the API data would be very large. How would it be processed without becoming painfully slow or running out of memory?
- How could the speed be improved while not exceeding API rate limits?

### Technical choices

Thanks to the [MTG documentation](https://docs.magicthegathering.io/), it was clearer to see how the API was meant to be used and what to expect. I also reached the realization that one would have to go through several pages to get all the data, so part of my initial analysis fell flat on it's face - it was no longer just a case of making one easy call and then process.

### Trade-offs

- Fibers over threads. Fibers are lightweight and one has more control over it than threads (which is soley at the mercy of the VM it's running on, and can sometimes behave randomly). For those reason, I chose fibers.
- Time complexity and space complexity. At the point of implementing fetching data, I choose to process the data page by page (sort into groups based on set or whatever the criteria would be) as it comes, instead of waiting to grab everything first. That meant going through each record and assigning them to a hash (hash because duplication would then be unlikely and hashes have a read/write of 0(1)), but in the long run, would be faster than retrieving before processing the huge result.

### Current Improvements

- Some classes can be called with different attributes from what they were originally meant to process. This makes them a lot more reusable. For example, The Card class can be called and asked to retrieve and groupe cards by other  attributes other than from 'set' or 'rarity'. In the same way, another set and array of colors can be passed to the class other than 'KTK' and [blue and red]. The ApiClient class can be reused in a future set class, and all it needs to know are attributes that are not even specific to any class.
- Graceful exit. Now, when you press ctrl+c, we don't get the typical Interrupt error, but the application prints a goodbye message before the process ends.
- Users can access a help command that highlights what commands are available, thanks to OptionParser that ships with Ruby.

### Future Improvements

While there has been some effort to make the code modular and clean, with classes not having to know what happens in another class, some parts could benefit from some refactor.
- More focus on error handling. This would include watching out for the error codes listed in the documentation when calls are made, and handling those error responses (when they come) to return more meaningful responses to users.
- Connected to error handling is respecting the API's rate limiting facilities. When rate-limit is exceeded, users typically get a 403 response informing them. While that might be a nice initial implementation (pause when you hit the limit), it might make even more sense to try to ensure we don't exceed the limit in the first place. In the response headers of every paginated request is information about the limit for a user (currently around 5000/hour), and the remaining limit. With that information, we could have a small pause between requests, so that we do not hit the limit very quickly. While this would make code execution take longer, we already benefit from using Ruby fibers to make reuests more concurrent.
- The card and api_client specs had some repeated test mocks/data that could have better abstracted into test helpers and re-used.

### Tests

Tests have been included to cover the base implementations.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
