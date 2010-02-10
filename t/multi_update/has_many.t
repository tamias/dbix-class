use strict;
use warnings;

use Test::More;
use Test::Exception;
use lib qw(t/lib);
use DBICTest;

plan tests => 2;

my $schema = DBICTest->init_schema();

my $track_no_lyrics = $schema->resultset ('Track')
              ->search ({ 'lyrics.lyric_id' => undef }, { join => 'lyrics' })
                ->first;

my $lyric = $track_no_lyrics->create_related ('lyrics', {
  lyric_versions => [
    { text => 'english doubled' },
    { text => 'english doubled' },
  ],
});
is ($lyric->lyric_versions->count, 2, "Two identical has_many's created");

# should the lyric_versions have pks? just replace them all?
$track_no_lyrics->update( { 
  title => 'Titled Updated by Multi Update',
  lyrics => {
    lyric_versions => [ 
      { text => 'Some new text' },
      { text => 'Other text' },
    ],
  },
});
is( $track_no_lyrics->title, 'Title Updated by Multi Update', 'title updated' );
is( $track_no_lyrics->lyrics->search_related('lyric_versions', { text => 'Other text' } )->count, 1, 'related record updated' );


my $link = $schema->resultset ('Link')->create ({
  url => 'lolcats!',
  bookmarks => [
    {},
    {},
  ]
});
is ($link->bookmarks->count, 2, "Two identical default-insert has_many's created");

# what should happen?
$link->update( {
  url => 'lolkittens!',
  bookmarks => [
    {}
  ]
});
is( $link->url, 'lolkittens!', 'url updated' );
is( $link->bookmarks->count, 1, 'One default bookmark' );
