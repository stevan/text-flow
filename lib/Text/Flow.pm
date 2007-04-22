
package Text::Flow;
use Moose;

use Text::Flow::Wrap;

our $VERSION = '0.01';

has 'check_height' => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

has 'wrapper' => (
    is       => 'rw',
    isa      => 'Text::Flow::Wrap',
    required => 1,
);

sub flow {
    my ($self, $text) = @_;
    
    my $paragraphs = $self->wrapper->disassemble_paragraphs($text);
    
    my @sections = ([]);
    foreach my $paragraph (@$paragraphs) {
        push @{$sections[-1]} => [];
        foreach my $line (@$paragraph) {
            unless ($self->check_height->($sections[-1])) {
                push @sections => [[]];                
            }            
            push @{$sections[-1]->[-1]} => $line;                
        }        
    }
    
    #use Data::Dumper;
    #warn Dumper \@sections;
    
    return map {
        chomp; $_;
    } map { 
        $self->wrapper->reassemble_paragraphs($_);
    } @sections;
}

1;

__END__

=pod

=head1 NAME

Text::Flow - Flexible text flowing and word wrapping for not just ASCII output.

=head1 SYNOPSIS

=head1 DESCRIPTION

The main purpose of this module is to provide text wrapping and flowing 
features without being tied down to ASCII based output and fixed-width fonts.

My needs were for sophisticated test control in PDF and GIF output 
formats in particular. 

=cut


