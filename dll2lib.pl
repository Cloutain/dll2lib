use Modern::Perl;
use autodie;
die "MSVC not present!" unless exists $ENV{VCINSTALLDIR};

my $dll = shift;
my $lib  = shift // $dll;	$lib =~ s/dll$/lib/i;
my $def  = $lib;						$def =~ s/lib$/def/i;

say "dll: $dll";
die "File not found!" unless -e $dll;

say "def: $def";
unlink $def if -e $def;
open DEF, '>', $def;
say DEF 'EXPORTS';
foreach(split /\n/, `dumpbin.exe /exports "$dll"`){
	next unless /\s+\d+\s+[\da-f]+\s+[\da-f]+\s+(?<func>.+)/i;
	say DEF $+{func};
}
close DEF;
say "lib: $lib";
my $res = `lib /nologo /def:"$def" /OUT:"$lib"`;
if($?){
	say "something were wrong:";
	say "\t\$?: $?";
	say "\tres: $res";
}
unlink $def;