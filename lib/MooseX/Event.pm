# ABSTRACT: A Node style event Role for Moose
package MooseX::Event;
{
  $MooseX::Event::VERSION = '0.3.0_2';
}
use Any::Moose ();
use Any::Moose '::Exporter';

use constant ROLE_CLASS => 'MooseX::Event::Role';

{
    my($import,$unimport,$init_meta) = any_moose('::Exporter')->build_import_methods(
        as_is => [qw( has_event has_events )],
        also => any_moose(),
        );

    sub import {
        my $class = shift;

        my $with_args = {};

        my @args;
        while (local $_ = shift @_) {
            if ( $_ eq '-alias' ) {
                $with_args->{'-alias'} = shift;
            }
            elsif ( $_ eq '-excludes' ) {
                $with_args->{'-excludes'} = shift;
            }
            else {
                push @args, $_;
            }
        }

        my $caller = caller();
        $class->$import( { into => $caller }, @args );

        # I would expect that 'base_class_roles' in setup_import_methods would
        # do the below, but no, it doesn't.
        if ( ! any_moose('::Util')->can('does_role')->( $caller, ROLE_CLASS ) ) {
             eval q{ require }.ROLE_CLASS;
             ROLE_CLASS->meta->apply( $caller->meta, %{$with_args} );
        }
    }

    sub unimport { goto $unimport; }
    *init_meta = $init_meta if defined $init_meta;
}



my %meta;
sub has_event {
    my $class = caller();
    for (@_) {
        $class->meta->add_attribute(
            "event:$_",
            init_arg => undef,
            is => 'ro',
            lazy => 1,
            default => sub {
                require MooseX::Event::Meta;
                MooseX::Event::Meta->new(object=>shift);
            },
            );
    }
}

BEGIN { *has_events = \&has_event }

no Any::Moose '::Exporter';


1;


__END__
=pod

=encoding utf-8

=head1 NAME

MooseX::Event - A Node style event Role for Moose

=head1 VERSION

version 0.3.0_2

=head1 SYNOPSIS

  package Example {
      use MooseX::Event;

      has_event 'pinged';

      sub ping {
          my $self = shift;
          $self->emit('pinged');
      }
  }

  use Event::Wrappable;

  my $example = Example->new;

  $example->on( pinged => event { say "Got a ping!" } );
  $example->on( pinged => event { say "Got another ping!" } );

  $example->ping; # prints "Got a ping!" and "Got another ping!"

  $example->remove_all_listeners( "pinged" ); # Remove all of the pinged listeners

  $example->once( pinged => event { say "First ping." } );
  $example->ping; $example->ping; # Only prints "First ping." once

  my $listener = $example->on( pinged => event { say "Ping" } );
  $example->remove_listener( pinged => $listener );

  $example->ping(); # Does nothing

=head1 DESCRIPTION

MooseX::Event provides an event framework for Moose classes that is inspired
by and similar to the one included with Node.js.  It provides class helpers
to let you declare that you emit named events, methods for you to emit
events with and methods to allow users of your class to declare event
listeners.  If you want to make your class emit events, you're in the right
place.

Alternatively, if you just want to use a suite of classes whose use an event
API like this one, you'll want to look at the L<ONE> module.
ONE provides a layer on top of AnyEvent that uses MooseX::Event as it's
interface.  This gives you an arguably nicer, and definitely more consistant
interface to write your event based programs.

This provides Node.js style events in a Role for Moose.  If you are looking
to write a program using a Node.js style event loop, see the L<ONE> module.

MooseX::Event is implemented as a Moose Role.  To add events to your object:

  use MooseX::Event;

It provides a helper declare what events your object supports:

  has_event 'event';
  ## or
  has_events qw( event1 event2 event3 );

Users of your class can now call the "on" method in order to register an event handler:

  $obj->on( event1 => event { say "I has an event"; } );

And clear their event listeners with:

  $obj->remove_all_listeners( "event1" );

Or add and clear just one listener:

  my $listener = $obj->on( event1 => event { say "Event here"; } );
  $obj->remove_listener( event1 => $listener );

You can trigger events from your class with the "emit" method:

  $self->emit( event1 => ( "arg1", "arg2", "argn" ) );

Events receive the object that they're attached to as their first argument. They are almost
a kind of fleeting sort of method:

   $obj->on( event1 => event {
       my $self = shift;
       my( $arg1, $arg2, $arg3 ) = @_;
       say "Arg3 was: $arg3\n";
   } );

At the bottom of your class, you should make sure you clean out your name space by calling
no MooseX::Event.

  no MooseX::Event;

=head1 HELPERS

=head2 sub has_event( *@event_names ) is export

=head2 sub has_events( *@event_names ) is export

Registers your class as being able to emit the event names listed.

=for test_synopsis use v5.10.0;

=head1 OTHER CLASSES LIKE THIS

=over

=item L<MooseX::Role::Listenable>

=item L<MooseX::Callbacks>

=item L<Object::Event>

=item L<Mixin::Event::Dispatch>

=item L<Class::Publisher>

=item L<Event::Notify>

=item L<Notification::Center>

=item L<Class::Observable>

=item L<Reflex::Role::Reactive>

=item L<Aspect::Library::Listenable>

=item L<Class::Listener>

=item L<http://nodejs.org/docs/v0.5.4/api/events.html>

=back

=head1 SEE ALSO



=over 4

=item *

L<MooseX::Event::Role|MooseX::Event::Role>

=item *

L<MooseX::Event::Role::ClassMethods|MooseX::Event::Role::ClassMethods>

=back

=head1 SOURCE

The development version is on github at L<http://https://github.com/iarna/MooseX-Event>
and may be cloned from L<git://https://github.com/iarna/MooseX-Event.git>

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 SUPPORT

=head2 Websites

More information can be found at:

=over 4

=item *

MetaCPAN

A modern, open-source CPAN search engine, useful to view POD in HTML format.

L<http://metacpan.org/release/MooseX-Event>

=back

=head2 Bugs / Feature Requests

Please report any bugs at L<https://github.com/iarna/MooseX-Event/issues>.

=head1 AUTHOR

Rebecca Turner <becca@referencethis.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Rebecca Turner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut

