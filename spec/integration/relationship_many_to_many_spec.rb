require 'spec_helper_integration'

describe 'Relationship - Many To Many with generated mappers' do
  before(:all) do
    setup_db

    insert_song 1, 'foo'
    insert_song 2, 'bar'

    insert_tag 1, 'good'
    insert_tag 2, 'bad'

    insert_song_tag 1, 1, 1
    insert_song_tag 2, 2, 2

    class Song
      attr_reader :id, :title, :song_tags, :tags, :good_tags

      def initialize(attributes)
        @id, @title, @song_tags, @tags, @good_tags = attributes.values_at(
          :id, :title, :song_tags, :tags, :good_tags
        )
      end
    end

    class Tag
      attr_reader :id, :name, :song_tags, :songs

      def initialize(attributes)
        @id, @name, @song_tags, @songs = attributes.values_at(:id, :name, :song_tags, :songs)
      end
    end

    class SongTag
      attr_reader :song_id, :tag_id

      def initialize(attributes)
        @song_id, @tag_id = attributes.values_at(:song_id, :tag_id)
      end
    end

    class TagMapper < DataMapper::Mapper::Relation::Base

      model         Tag
      relation_name :tags
      repository    :postgres

      map :id,   Integer, :key => true
      map :name, String

      has 0..n, :song_tags, SongTag
      has 0..n, :songs, Song, :through => :song_tags
    end

    class SongTagMapper < DataMapper::Mapper::Relation::Base

      model         SongTag
      relation_name :song_tags
      repository    :postgres

      map :song_id, Integer, :key => true
      map :tag_id,  Integer, :key => true
    end

    class SongMapper < DataMapper::Mapper::Relation::Base
      model         Song
      relation_name :songs
      repository    :postgres

      map :id,    Integer, :key => true
      map :title, String

      has 0..n, :song_tags, SongTag

      has 0..n, :tags, Tag, :through => :song_tags

      has 0..n, :good_tags, Tag, :through => :song_tags do
        restrict { |r| r.tag_name.eq('good') }
      end
    end
  end

  it 'loads associated song_tags for songs' do
    mapper = DataMapper[Song].include(:song_tags)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('foo')
    song1.song_tags.should have(1).item
    song1.song_tags.first.song_id.should eql(song1.id)
    song1.song_tags.first.tag_id.should eql(1)

    song2.title.should eql('bar')
    song2.song_tags.should have(1).item
    song2.song_tags.first.song_id.should eql(song2.id)
    song2.song_tags.first.tag_id.should eql(2)
  end

  it 'loads associated tags for songs' do
    pending "this passes when run in isolation. probably some post-run clean up issue" if RUBY_VERSION < '1.9'
    mapper = DataMapper[Song].include(:tags)
    songs  = mapper.to_a

    songs.should have(2).items

    song1, song2 = songs

    song1.title.should eql('foo')
    song1.tags.should have(1).item
    song1.tags.first.name.should eql('good')

    song2.title.should eql('bar')
    song2.tags.should have(1).item
    song2.tags.first.name.should eql('bad')
  end

  it 'loads associated tags with name = good' do
    mapper = DataMapper[Song].include(:good_tags)
    songs  = mapper.include(:good_tags).to_a

    songs.should have(1).item

    song = songs.first

    song.title.should eql('foo')
    song.good_tags.should have(1).item
    song.good_tags.first.name.should eql('good')
  end

  it 'loads associated song_tags for tags' do
    mapper = DataMapper[Tag].include(:song_tags)
    tags   = mapper.to_a

    tags.should have(2).item

    tag1, tag2 = tags

    tag1.name.should eql('good')
    tag1.song_tags.should have(1).item
    tag1.song_tags.first.song_id.should eql(tag1.id)

    tag2.name.should eql('bad')
    tag2.song_tags.should have(1).item
    tag2.song_tags.first.tag_id.should eql(tag2.id)
  end

  it 'loads associated songs' do
    mapper = DataMapper[Tag].include(:songs)
    tags   = mapper.to_a

    tags.should have(2).item

    tag1, tag2 = tags

    tag1.name.should eql('good')
    tag1.songs.should have(1).item
    tag1.songs.first.title.should eql('foo')

    tag2.name.should eql('bad')
    tag2.songs.should have(1).item
    tag2.songs.first.title.should eql('bar')
  end

  it 'uses the same join relation for both sides' do
    pending "reversing joins to re-use existing relation nodes is not implemented yet"

    relation_a = DataMapper[Song].include(:tags).relation
    relation_b = DataMapper[Tag].include(:songs).relation

    relation_a.should eql(relation_b)
  end
end
