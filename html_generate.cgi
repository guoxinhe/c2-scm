#!/usr/bin/perl

use CGI qw/:standard/;

use strict;
use Fcntl qw(:seek);

my $num_days = 9;
my $total=0;

my $CSS = <<EOCSS;
<!--
td {text-align: center}
table {background: lightgrey}
td.category {vertical-align:top}

.pass {background: #00ff00; font-weight:bold}
.fail {background: red;  font-weight:bold}
.na   {background: grey}
.run  {background: #ffff00; font-weight:bold}
-->
EOCSS

sub check_for_results_string {
  my $log = shift;

  open (LOG, $log) or return (undef, undef);

  seek (LOG, -200, SEEK_END);

  my $tail;

  {
    local $/ = undef;

    $tail = <LOG>;
  }

  close (LOG);

  my ($n_warning, $n_error) =
    ($tail =~ m-^BUILD RESULTS: warnings (\d+)/(\d+) errors-m);

  return ($n_warning, $n_error);
}

sub print_project_build_info {
    print "  <b><font color=blue  >Upload time: </font></b> " . localtime() . " (gmtime: " . gmtime(). ")<br>\n";
    print <<HTML;
  <b><font color=blue  >Project  : </font></b> $ENV{SDKENV_Project}<br>
  <b><font color=blue  >Server   : </font></b> $ENV{SDKENV_Server}<br>
  <b><font color=blue  >Script   : </font></b> $ENV{SDKENV_Script}<br>
  <b><font color=blue  >Overview : </font></b> $ENV{SDKENV_Overview}<br>
  <b><font color=blue  >Setting  : </font></b> $ENV{SDKENV_Setting}<br>
HTML
}
sub print_top_results {

  my $results_dir; 
  my $urlpre;

  if (defined($ENV{SDK_RESULTS_DIR})) {
    $results_dir = $ENV{SDK_RESULTS_DIR};
  }else{
    $results_dir = "$ENV{PWD}/../build_result";
  }

  if (defined($ENV{SDKENV_URLPRE})) {
    $urlpre = $ENV{SDKENV_URLPRE};
  }else{
    $urlpre = "http://127.0.0.1"
  }

  opendir(DIR, $results_dir) or die "Couldn't open $results_dir: $!\n";

  my $log_num = grep /^(\d{2}[0,1][0-9][0-3][0-9])\.txt$/i, readdir(DIR);
  if ($log_num<10) {
    $num_days = $log_num-1;
  }

  opendir(DIR, $results_dir);
  my @dates = (sort({ $b cmp $a} grep(s/^(\d{2}[0,1][0-9][0-3][0-9])\.txt$/$1/, readdir(DIR))))[0..$num_days];

  my %results;

  for my $d (@dates) {
    open (RES, "${results_dir}/$d.txt") or die "Opening $d: $!\n";
    while (<RES>) {
      /^.*:.*:.*$/ || next;
      my ($test, $res, $logfile) = split(/:/);
      $results{$test}{$d} = [$res, $logfile];
    }
  }

  print "Click on <b>FAIL</b> link to see log of failures<br>";

  print "<table border=1>";
  print "<tr><th>Category</th><th>" .
    join ("</th><th>", @dates) . "</th></tr>";

    my $newrow = 0;

    for my $test (keys (%results)) {
      print "<tr>" if ($newrow);

      # Make test red if the most recent test failed
      my $testclass = "na";
      if (exists($results{$test}{$dates[0]})) {
        $testclass = $results{$test}{$dates[0]}[0] == 0 ? "pass" : $results{$test}{$dates[0]}[0] == 2 ? "run" : "fail";
      }


      print "<td class=${testclass}>$test</td>";

      for my $d (@dates) {
        my $class = "na";
        my $status = "";

        if (exists($results{$test}{$d})) {
          my ($res, $log) = @{$results{$test}{$d}};
          $class = $res == 0 ? "pass" : $res == 2 ? "run" : "fail";

          my ($n_warning, $n_error) = check_for_results_string($log);

          $status = ($n_error) ? "${n_warning}/${n_error}" : uc($class);

          $log =~ s-$results_dir-$urlpre-;

          $status = "<a href='$log' title='gettin jiggy'>${status}</a>";
        }
        print "<td class='${class}'>${status}</td>";
      }
      print "</tr>";
      $newrow = 1;
    }
  

  print "</table>";

}

#print header;
if (defined($ENV{SDKENV_Title})) {
    print start_html(-title=>"$ENV{SDKENV_Title}", -style=>{'code'=>$CSS});
    print h1("$ENV{SDKENV_Title}");
}else{
print start_html(-title=>"C2 $ENV{SDK_TARGET_ARCH} SDK Daily Build Results",
                 -style=>{'code'=>$CSS});

print h1("C2 $ENV{SDK_TARGET_ARCH} SDK Daily Build Results");
}

print_top_results();
print_project_build_info();

print end_html;
