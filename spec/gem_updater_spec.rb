require 'spec_helper'

describe GemUpdater::Updater do
  let( :gemfile ) do
    instance_double( GemUpdater::GemFile, changes: { fake_gem: { versions: { old: '0.1', new: '0.2' } } } )
  end

  let( :source_page_parser ) do
    instance_double( GemUpdater::SourcePageParser, changelog: 'fake_gem_changelog_url' )
  end

  before :each do
    allow( GemUpdater::GemFile ).to receive( :new ).and_return( gemfile )
    allow( GemUpdater::SourcePageParser ).to receive( :new ).and_return( source_page_parser )
  end

  describe '#update' do
    before :each do
      allow( gemfile ).to receive( :update! )
      allow( gemfile ).to receive( :compute_changes )
      allow( subject ).to receive( :find_source )     { 'fake_gem_changelog_url' }
      subject.update!( [] )
    end

    it 'updates gemfile' do
      expect( gemfile ).to have_received( :update! )
    end

    it 'computes changes' do
      expect( gemfile ).to have_received( :compute_changes )
    end

    it 'gets changelogs' do
      expect( gemfile.changes[ :fake_gem ][ :changelog ] ).to eq 'fake_gem_changelog_url'
    end
  end

  describe '#output_diff' do
    before :each do
      allow( gemfile ).to receive( :changes ) do
        { fake_gem_1: { changelog: 'fake_gem_1_url', versions: { old: '1.0', new: '1.1' } },
        fake_gem_2: { changelog: 'fake_gem_2_url', versions: { old: '0.4', new: '0.4.2' } } }
      end
      allow( Bundler.ui ).to receive( :info )
      subject.output_diff
    end

    it 'outputs changes' do
      expect( Bundler.ui ).to have_received( :info ).with( <<CHANGELOG
* fake_gem_1 1.0 → 1.1
[changelog](fake_gem_1_url)

* fake_gem_2 0.4 → 0.4.2
[changelog](fake_gem_2_url)

CHANGELOG
      )
    end
  end


  describe '#format_diff' do
    before :each do
      allow( gemfile ).to receive( :changes ) do
        { fake_gem_1: { changelog: 'fake_gem_1_url', versions: { old: '1.0', new: '1.1' } },
        fake_gem_2: { changelog: 'fake_gem_2_url', versions: { old: '0.4', new: '0.4.2' } } }
      end
    end

    it 'contains changes' do
      [ "* fake_gem_1 1.0 → 1.1\n[changelog](fake_gem_1_url)\n\n", "* fake_gem_2 0.4 → 0.4.2\n[changelog](fake_gem_2_url)\n\n" ].each do |msg|
        expect( subject.format_diff ).to include msg
      end
    end
  end


  describe '#find_source' do
    context 'when it is Bundler::Source::Rubygems' do
      let( :ruby_gems_fetcher ) { OpenStruct.new( source_uri: 'fake_gem_url' ) }

      before :each do
        allow( ruby_gems_fetcher ).to receive( :source_uri )
        allow( GemUpdater::RubyGemsFetcher ).to receive( :new ) { ruby_gems_fetcher }
        subject.send( :find_source, 'fake_gem', Bundler::Source::Rubygems.new )
      end

      it 'delegates to RubyGems fetcher' do
        expect( ruby_gems_fetcher ).to have_received( :source_uri )
      end
    end

    context 'when it is Bundler::Source::Git' do
      let( :git_source ) { OpenStruct.new( uri: 'git://fakeurl.com/gem.git' ) }

      before :each do
        allow( Bundler::Source::Git ).to receive( :=== ) { true }
      end

      it 'returns git url converted to http url' do
        expect( subject.send( :find_source, 'fake_gem', git_source ) ).to eq 'http://fakeurl.com/gem'
      end
    end
  end
end
