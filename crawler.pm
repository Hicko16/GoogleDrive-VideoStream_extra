use HTTP::Cookies;
#use HTML::Form;
use URI;
use LWP::UserAgent;
use LWP;
use HTTP::Request::Common;
use strict;
require '../common.config';


package TOOLS_CRAWLER;

######
#

=head1 NAME

 Crawler Toolkit - version 20070325

=head1 DESCRIPTION

  A package that provides functinality to crawl a website.

=head2 Dependencies

=over

=item *

  Perl 5.8 or later, supports ActivePerl

=back

=head2 Constants

=over

=item * SUCCESS

  An array index representing success.

=item * FAILURE

  An array index representing failure.

=item * PARTIAL_SUCCESS

  An array index representing partial success.

=back

=cut

#
###


use constant SUCCESS         => 1;
use constant FAILURE         => 3;
use constant PARTIAL_SUCCESS => 2;




my $ident = CONFIG->USERAGENT; # this gets logged, so it should be representative
my $ua = LWP::UserAgent->new;	   # call the constructor method for this object
$ua->agent($ident);		   # set the identity
$ua->timeout(CONFIG->HTTP_TIMEOUT);# set the timeout
my $cookie_jar = HTTP::Cookies->new();
$ua->cookie_jar($cookie_jar);
$ua->default_headers->push_header('Accept' => "image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, application/x-shockwave-flash, application/vnd.ms-excel, application/vnd.ms-powerpoint, application/msword, */*");
$ua->default_headers->push_header('Accept-Language' => "en-us");
$ua->timeout(30);
my $ignoreCookies;


######
#

=head1 METHODS

=cut

#
###


sub setHeaders($){
	my $headers = shift;

	while ($headers =~ m%\|%){
		my ($key,$value) = $headers =~ m%^([^\:]+)\:([^\|]+)\|%;
		$headers =~ s%^([^\|]+)\|%%;
		if ($key eq 'User-Agent'){
			$ua->agent($value);		   # set the identity
		}else{
			$ua->default_headers->push_header($key => $value);
		}


	}
	my ($key,$value) = $headers =~ m%([^\:]+)\:(.*?)$%;
	$ua->default_headers->push_header($key => $value);

}

sub setReferer($){
	my $referer = shift;
	$ua->default_headers->push_header('Referer' => $referer);
}
sub ignoreCookies(){
        $ignoreCookies=1;
}


######
#

=head2 complexGET()

=over

  complexGET() will perform GET operation request.

  The complex indicates that this operation can be provided with success and failure criteria and can be provided with instruction to fetch values from the web page.

  This method makes a subcall to complexWEB() which is a method for performing generic web retrievals.

=item Parameters

=over

=item * fullly qualified web url

  This the fully qualified web url to send the request to.  May include parameters for parameter passing in the URL.

=item * file

  This is a file to store the response packet.  This will only be used if CONFIG->DEBUG is set.

=item * success criteria

  An array containing strings that must be present for a successful crawl.

=item * failure criteria

  An array containing strings that, if present, represents a failed crawl.

  * Note:  if the response packet has a recognized error code for a return code, the FAILURE state is set, regardless if the failure criteria are matched.

=item * fetch variables

  This is a 2 dimensional array in list format.

  (string criteria, string match until, string pattern match to the right)

  For example, if I have a string such as <input name="myname" value="myvalue"> in my web page and I want the value myvalue, I would pass in

    ('<input name="myname" value="', '"', '">')

  For example, if I have a string such as <input value="myvalue" name="myname"> in my web page and I want the value myvalue, I would pass in

    ('<input value="', '"', '" name="myname">')

  You can pass in multiple fetches (hence the two dimensional aspect), like:

    (('<input name="myname" value="', '"', '">'),('<input value="', '"', '" name="myname">'))

=back

=item Returns

  Because you can only return scalars or lists (lists are equivalent to one dimensional arrays) from methods in Perl, we return a list of the following format:

  (integer representing state - SUCCESS, FAILURE, or PARTIAL SUCCESS, string representing state,
  integer representing fetch variable, string representing fetch value,
  ...)

  For each fetch variable set defined in fetch, we retrieve a unique index for each, assigned by order requested.  Each fetch variable request can result in multiple values, based on the number of matches.

  *Note:  A PARTIAL_SUCCESS is returned if at least one of the success criteria was not matched.

=back

=cut

#
###
sub complexGET($$@@@){
  my $site = $_[0];
  my $file = $_[1];
  my @successStrings = @{$_[2]};
  my @failureStrings = @{$_[3]};
  my @fetch = @{$_[4]};


  my @successResponses;
  my @failureResponses;
  my @fetchResults;
  my @returnResults;

  my $req = new HTTP::Request GET => "$site";
  $cookie_jar->add_cookie_header($req) unless ($ignoreCookies);

  return complexWEB($site,$file,\@successStrings,\@failureStrings,\@fetch, $req);
}



######
#

=head2 complexPOST()

=over

  complexPOST() will perform POST operation request.

  The complex indicates that this operation can be provided with success and failure criteria and can be provided with instruction to fetch values from the web page.

  This method makes a subcall to complexWEB() which is a method for performing generic web retrievals.

=item Parameters

=over

=item * fullly qualified web url

  This the fully qualified web url to send the request to.  May include parameters for parameter passing in the URL.

=item * file

  This is a file to store the response packet.  This will only be used if CONFIG->DEBUG is set.

=item * success criteria

  An array containing strings that must be present for a successful crawl.

=item * failure criteria

  An array containing strings that, if present, represents a failed crawl.

  * Note:  if the response packet has a recognized error code for a return code, the FAILURE state is set, regardless if the failure criteria are matched.

=item * fetch variables

  This is a 2 dimensional array in list format.

  (string criteria, string match until, string pattern match to the right)

  For example, if I have a string such as <input name="myname" value="myvalue"> in my web page and I want the value myvalue, I would pass in

    ('<input name="myname" value="', '"', '">')

  For example, if I have a string such as <input value="myvalue" name="myname"> in my web page and I want the value myvalue, I would pass in

    ('<input value="', '"', '" name="myname">')

  You can pass in multiple fetches (hence the two dimensional aspect), like:

    (('<input name="myname" value="', '"', '">'),('<input value="', '"', '" name="myname">'))


=item * parameter list

  This is the parameter list that is passed in the header of the request.

=back

=item Returns

  Because you can only return scalars or lists (lists are equivalent to one dimensional arrays) from methods in Perl, we return a list of the following format:

  (integer representing state - SUCCESS, FAILURE, or PARTIAL SUCCESS, string representing state,
  integer representing fetch variable, string representing fetch value,
  ...)

  For each fetch variable set defined in fetch, we retrieve a unique index for each, assigned by order requested.  Each fetch variable request can result in multiple values, based on the number of matches.

  *Note:  A PARTIAL_SUCCESS is returned if at least one of the success criteria was not matched.

=back

=cut

#
###
sub complexPOST($$@@@$){
  my $site = $_[0];
  my $file = $_[1];
  my @successStrings = @{$_[2]};
  my @failureStrings = @{$_[3]};
  my @fetch = @{$_[4]};
  my $param = $_[5];

  my @successResponses;
  my @failureResponses;
  my @fetchResults;
  my @returnResults;

  my $req = new HTTP::Request POST => "$site";
  $req->content_type("application/x-www-form-urlencoded");
  $cookie_jar->add_cookie_header($req) unless ($ignoreCookies);
  $req->content($param);
  return complexWEB($site,$file,\@successStrings,\@failureStrings,\@fetch, $req);
}



sub complexJSONPOST($$@@@$){
  my $site = $_[0];
  my $file = $_[1];
  my @successStrings = @{$_[2]};
  my @failureStrings = @{$_[3]};
  my @fetch = @{$_[4]};
  my $param = $_[5];

  my @successResponses;
  my @failureResponses;
  my @fetchResults;
  my @returnResults;

  my $req = new HTTP::Request POST => "$site";
  $req->content_type("application/json");
  $cookie_jar->add_cookie_header($req) unless ($ignoreCookies);
  $req->content($param);
  return complexWEB($site,$file,\@successStrings,\@failureStrings,\@fetch, $req);
}
######
#

=head2 complexWEB()

=over

  complexWEB() will perform either a GET or POST operation operation request.

  The complex indicates that this operation can be provided with success and failure criteria and can be provided with instruction to fetch values from the web page.

  This method makes a subcall to complexWEB() which is a method for performing generic web retrievals.

=item Parameters

=over

=item * fullly qualified web url

  This the fully qualified web url to send the request to.  May include parameters for parameter passing in the URL.

=item * file

  This is a file to store the response packet.  This will only be used if CONFIG->DEBUG is set.

=item * success criteria

  An array containing strings that must be present for a successful crawl.

=item * failure criteria

  An array containing strings that, if present, represents a failed crawl.

  * Note:  if the response packet has a recognized error code for a return code, the FAILURE state is set, regardless if the failure criteria are matched.

=item * fetch variables

  This is a 2 dimensional array in list format.

  (string criteria, string match until, string pattern match to the right)

  For example, if I have a string such as <input name="myname" value="myvalue"> in my web page and I want the value myvalue, I would pass in

    ('<input name="myname" value="', '"', '">')

  For example, if I have a string such as <input value="myvalue" name="myname"> in my web page and I want the value myvalue, I would pass in

    ('<input value="', '"', '" name="myname">')

  You can pass in multiple fetches (hence the two dimensional aspect), like:

    (('<input name="myname" value="', '"', '">'),('<input value="', '"', '" name="myname">'))


=item * request packet

  The built request packet.

=back

=item Returns

  Because you can only return scalars or lists (lists are equivalent to one dimensional arrays) from methods in Perl, we return a list of the following format:

  (integer representing state - SUCCESS, FAILURE, or PARTIAL SUCCESS, string representing state,
  integer representing fetch variable, string representing fetch value,
  ...)

  For each fetch variable set defined in fetch, we retrieve a unique index for each, assigned by order requested.  Each fetch variable request can result in multiple values, based on the number of matches.

  *Note:  A PARTIAL_SUCCESS is returned if at least one of the success criteria was not matched.

=back

=cut

#
###
sub complexWEB($$@@@$){

  use Fcntl ':flock'; # import LOCK_* constants

  my $site = $_[0];
  my $file = $_[1];
  my @successStrings = @{$_[2]};
  my @failureStrings = @{$_[3]};
  my @fetch = @{$_[4]};
  my $req = $_[5];

  my @successResponses;
  my @failureResponses;
  my @fetchResults;
  my @returnResults;


  my $res = $ua->request($req); # make the request
  for (my $j=0; $j<=CONFIG->HTTP_RETRYCOUNT && !($res->is_success or ($res->code >= 300 and $res->code < 400));$j++){
    $res = $ua->request($req); # make the request
  }

  $cookie_jar->extract_cookies($res) unless ($ignoreCookies);


  for (my $i=0; $i<($#successStrings + 1); $i++){
    $successResponses[$i][0] = $successStrings[$i];
    $successResponses[$i][1] = 0;
  }
  for (my $i=0; $i<($#failureStrings + 1); $i++){
    $failureResponses[$i][0] = $failureStrings[$i];
    $failureResponses[$i][1] = 0;
  }

  if (CONFIG->DEBUG){
    print STDERR $req->as_string;
    print STDERR $res->decoded_content;
  }


  if($res->is_success or ($res->code >= 300 and $res->code < 400)){

    my $block = $res->decoded_content . "\n";

    while (my ($line) = $block =~ m%([^\n]*)\n%){

	  if (CONFIG->REMOVE_NEWLINE){
	      $block =~ s%\n%%g;

		  $line = $block;
		  $block = '';
	  }else{
	  	$block =~ s%[^\n]*\n%%;
	  }


      if ($line =~ m%Location\: %){
        my ($address) = $line =~ m%Location\: ([^\s]+)$%;
        return complexGET($address,$file,\@successStrings,\@failureStrings,\@fetch);
      }

      for (my $i=0; $i<($#successStrings + 1); $i++){
        if ($line =~ m%$successResponses[$i][0]%){
          $successResponses[$i][1] = 1;
        }
      }
      for (my $i=0; $i<($#failureStrings + 1); $i++){
        if ($line =~ m%$failureResponses[$i][0]%){
          $failureResponses[$i][1] = 1;
        }
      }
      my $j=0;
      for (my $i=0; $i<($#fetch +1); $i+=3){
        while ($line =~ m%${fetch[$i]}[^$fetch[$i+1]]+$fetch[$i+2]%){
          my ($result) = $line =~ m%$fetch[$i]([^$fetch[$i+1]]+)$fetch[$i+2]%;
          $result =~ s%\\/%/%g;
          push(@{$fetchResults[$i/3]},$result);
          $line =~ s%$fetch[$i]([^$fetch[$i+1]]+)$fetch[$i+2]%%;
        }

      }

    }

    #pack results
    my $k=0;
    for (my $i=0; $i< ($#fetchResults + 1);$i++){
      for (my $j=0; $j< ($#{$fetchResults[$i]} + 1);$j++){
        $returnResults[$k++] = $i;
		$returnResults[$k++] = $fetchResults[$i][$j];
        print STDERR "... $i = $fetchResults[$i][$j]\n" if (CONFIG->DEBUG);
      }
      print STDERR "\t\tfound (fetch criteria \#$i) --> ". ($#{$fetchResults[$i]}+1) . "\n"  if (CONFIG->DEBUG);
    }

    my $success = "";
    for (my $i=0; $i<($#successResponses + 1); $i++){
      if ($successResponses[$i][1]==0){
        if ($success ne ""){$success .= ",";}
        $success .= "$successResponses[$i][0]";
      }
    }
    my $failure = "";
    for (my $i=0; $i<($#failureResponses + 1); $i++){
      if ($failureResponses[$i][1]==1){
        if ($failure ne ""){$failure .= ",";}
        $failure .= "$failureResponses[$i][0]";
      }
    }

    if ($file ne ''){
		open(OUTPUT,">" . $file) or die ("Cannot save to $file ".$!);
		print OUTPUT $res->decoded_content;
		close(OUTPUT);
    }

    if ($success eq "" and $failure eq ""){
      print STDERR "\tPASS [$site]\n" if (CONFIG->DEBUG);
      print STDERR "(saved to $file)\n" if (CONFIG->DEBUG);
      print STDERR "\n" if (CONFIG->DEBUG);
      return (SUCCESS,"PASS [$site]",@returnResults);
    }elsif ($success ne "" and $failure eq ""){
      print STDERR "\t***PARTIAL PASS*** (not satisfied: $success) [$site]\n" if (CONFIG->DEBUG);
      print STDERR "(saved to $file)\n" if (CONFIG->DEBUG);
      print STDERR "\n" if (CONFIG->DEBUG);
      return (PARTIAL_SUCCESS,"***PARTIAL PASS*** (not satisfied: $success) [$site]",@returnResults);
    }elsif ($success eq "" and $failure ne ""){
      print STDERR "\tFAIL (failed: $failure) [$site]\n" if (CONFIG->DEBUG);
      print STDERR "(saved to $file)\n" if (CONFIG->DEBUG);
      print STDERR "\n" if (CONFIG->DEBUG);
      return (FAILURE,"FAIL (failed: $failure) [$site]",@returnResults);
    }elsif ($success ne "" and $failure ne ""){
      print STDERR "\tFAIL (not satisfied: $success, failed: $failure) [$site]\n" if (CONFIG->DEBUG);
      print STDERR "(saved to $file)\n" if (CONFIG->DEBUG);
      print STDERR "\n" if (CONFIG->DEBUG);
      return (FAILURE,"FAIL (not satisfied: $success, failed: $failure) [$site]",@returnResults);
    }
  }else{
    print STDERR "\tFAIL (returned code \#".$res->code.") [$site]\n" if (CONFIG->DEBUG);
    return (FAILURE,"FAIL (returned code \#".$res->code.") [$site]",@returnResults);
  }

}



######
#

=head2 simpleGET()

=over

  simpleGET() will perform GET operation request.

  The simple indicates that this operation operation does not allow success and failure criteria or fetch variables.

  This method makes a subcall to simpleWEB() which is a method for performing generic web retrievals.

=item Parameters

=over

=item * fullly qualified web url

  This the fully qualified web url to send the request to.  May include parameters for parameter passing in the URL.

=back

=item Returns

  SUCCESS if a success return code is received in the response packet.
  FAILURE if a failure return code is received in the response packet.

=back

=cut

#
###
sub simpleGET($){
  my $site = shift;

  my $req = new HTTP::Request GET => "$site";
  return simpleWEB($site, $req);

}

sub simplePOST($){
  my $site = shift;

  my $req = new HTTP::Request POST => "$site";
  $req->content_type("application/x-www-form-urlencoded");
  $cookie_jar->add_cookie_header($req) unless ($ignoreCookies);
  $req->content(' ');
  return simpleWEB($site, $req);

}


######
#

=head2 simpleWEB()

=over

  simpleWEB() will perform either a GET or HEAD operation request.

  The simple indicates that this operation operation does not allow success and failure criteria or fetch variables.

=item Parameters

=over

=item * fullly qualified web url

  This the fully qualified web url to send the request to.  May include parameters for parameter passing in the URL.

=item * request packet

  The built request packet.

=back

=item Returns

  SUCCESS if a success return code is received in the response packet.
  FAILURE if a failure return code is received in the response packet.

=back

=cut

#
###
sub simpleHEAD($){
  my $site = shift;

  my $req = new HTTP::Request HEAD => "$site";
  return simpleWEB($site, $req);

}




######
#

=head2 simpleWEB()

=over

  simpleHEAD() will perform HEAD operation request.

  The simple indicates that this operation operation does not allow success and failure criteria or fetch variables.

  This method makes a subcall to simpleWEB() which is a method for performing generic web retrievals.

=item Parameters

=over

=item * fullly qualified web url

  This the fully qualified web url to send the request to.  May include parameters for parameter passing in the URL.

=back

=item Returns

  SUCCESS if a success return code is received in the response packet.
  FAILURE if a failure return code is received in the response packet.

=back

=cut

#
###
sub simpleWEB($$){
  my $site = shift;
  my $req = shift;

  $cookie_jar->add_cookie_header($req) unless ($ignoreCookies);
  my $res = $ua->request($req); # make the request
  for (my $j=0; $j<CONFIG->HTTP_RETRYCOUNT && !($res->is_success or ($res->code >= 300 and $res->code < 400));$j++){
    $res = $ua->request($req); # make the request
  }
  $cookie_jar->extract_cookies($res) unless ($ignoreCookies);

  if (CONFIG->DEBUG){
    print STDERR $req->as_string;
    print STDERR $res->as_string;
  }

  if($res->is_success or ($res->code >= 300 and $res->code < 400)){
    print STDERR "\tPASS [$site]\n" if (CONFIG->DEBUG);
    print STDERR "\n" if (CONFIG->DEBUG);
    return (SUCCESS, "PASS [$site]");
  }else{
    print STDERR "\tFAIL (returned code \#".$res->code.") [$site]\n" if (CONFIG->DEBUG);
    print STDERR "\n" if (CONFIG->DEBUG);
    return (FAILURE, "FAIL (returned code \#".$res->code.") [$site]");
  }

}


######
#

=head2 fixViewState()

=over

  fixViewState() fixes the raw view state values found on a webpage

=item Parameters

=over

=item * view state value

  The view state value retrieved from a web page

=back

=item Returns

  A string representing the view state variable that may be transported in a request packet.

=back

=cut

#
###
sub fixViewState($){

  my $viewState = shift;
  $viewState =~ s#\+#%2B#g;
  $viewState =~ s#\=#%3D#g;
  return $viewState;

}

# we need to return from the file with a >0 condition;
1;

__END__

=head1 AUTHORS

  (c) IBM Canada Ltd

=over

=item * 2007.03.25 - added comments - Dylan Durdle

=item * 2006.09 - initial - Dylan Durdle

=back



