package # hide from PAUSE
    DBIx::Class::Storage::DBI::StrptimeParserMaker;

use strict;
use warnings;
use Sub::Name ();

sub make_parser {
  my ($class, $dest_class, $methods) = @_;

  while (my ($type, $format) = each %$methods) {
    $format = { parse => $format, format => $format } if not ref $format;

    for my $action (qw/parse format/) {
      my $method = "${dest_class}::${action}_$type";

      {
        no strict 'refs';

        my $parser;
        my $strptime_method;

        *$method = Sub::Name::subname $method => sub {
          shift;
          require DateTime::Format::Strptime;
          $parser ||= DateTime::Format::Strptime->new(
            pattern  => $format->{$action},
            on_error => 'croak',
          );
          $strptime_method ||= $parser->can("${action}_datetime");
          return $parser->$strptime_method(shift);
        };
      }
    }
  }
}

1;
# vim:et sts=2 sw=2 tw=80:
