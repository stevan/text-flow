
package Text::Flow::Wrap;
use Moose;

our $VERSION = '0.01';

has 'check_width' => (
    is       => 'rw',
    isa      => 'CodeRef',
    required => 1,
);

has 'word_boundry'      => (is => 'rw', isa => 'Str', default => " ");
has 'paragraph_boundry' => (is => 'rw', isa => 'Str', default => "\n");

has 'word_break'        => (is => 'rw', isa => 'Str', default => " ");
has 'line_break'        => (is => 'rw', isa => 'Str', default => "\n");
has 'paragraph_break'   => (is => 'rw', isa => 'Str', default => "\n\n");

sub wrap {
    my ($self, $text) = @_;
    $self->reassemble_paragraphs(
        $self->disassemble_paragraphs($text)
    );
}

sub reassemble_paragraphs {
    my ($self, $paragraphs) = @_;
    join $self->paragraph_break => map { 
        $self->reassemble_paragraph($_) 
    } @$paragraphs;
}

sub reassemble_paragraph {
    my ($self, $paragraph) = @_;
    join $self->line_break => @$paragraph;
}

sub disassemble_paragraphs {
    my ($self, $text) = @_;
    
    my @paragraphs = split $self->paragraph_boundry => $text;
    
    my @output; 
    foreach my $paragraph (@paragraphs) { 
        push @output => $self->disassemble_paragraph($paragraph); 
    }
    
    return \@output;
}

sub disassemble_paragraph {
    my ($self, $text) = @_;
    
    my @output = ('');
    
    my @words = split $self->word_boundry => $text;
    
    my $work_break = $self->word_break;    
    
    foreach my $word (@words) {
        my $padded_word = ($word . $work_break);
        my $canidate    = ($output[-1] . $padded_word);
        if ($self->check_width->($canidate)) {
            $output[-1] = $canidate;
        }
        else {
            push @output => ($padded_word);
        }
    }
    
    # NOTE:
    # remove that final word break character
    chop $output[-1] if substr($output[-1], -1, 1) eq $work_break;
    
    return \@output;    
}

1;

__END__

=pod

=head1 NAME

Text::Flow::Wrap - Flexible word wrapping for not just ASCII output.

=head1 SYNOPSIS

  use Text::Flow::Wrap;
  
  # for regular ASCII usage ...
  my $wrapper = Text::Flow::Wrap->new(
      check_width => sub { length($_[0]) < 70 },
  );
  
  # for non-ASCII usage ...
  my $wrapper = Text::Flow::Wrap->new(
      check_width => sub { $gd_text->width($_[0]) < 500 },
  );
  
  my $text = $wrapper->wrap($orig_text);  

=head1 DESCRIPTION

The main purpose of this module is to provide text wrapping features 
without being tied down to ASCII based output and fixed-width fonts.

My needs were for sophisticated test control in PDF and GIF output 
formats in particular. 

=cut


