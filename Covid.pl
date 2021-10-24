#!/usr/bin/perl
####################################
## COVID! Perl Bot IRC            ##
## Created By iJoo at WFH         ##
## still under development        ##
## Jakarta 01/may/2020            ##
####################################
use IO::Socket;
use Text::Capitalize qw( scramble_case );
use Time::Seconds;
use POSIX;

$acak = int(rand(99999)) + 10000;
$botnick = "PenJaGa";
$nickalt = "$botnick-$acak";
$botpass = "xxxxxx";
$admin = "ijoo";
$server = "irc.chating.id";
$port = "6667";
$basechan = "#ijoo";
$notc = "[\002C\037o\037VID\002]";

##### Don't edit below here. #####
my $pid=fork;
exit if $pid;
die "Masalah fork: $!" unless defined($pid);

&connect;
sub connect(){
 $sock = IO::Socket::INET->new(PeerAddr => $server,
                               PeerPort => $port,
                               Proto => "tcp") or die "Can't connect to $server.\n";
 print $sock "user $botnick $botnick $botnick :$notc\n";
 print $sock "nick $botnick \n";
}
$countaway = 0;
$utime = time();
$chanonly = scramble_case('masukan perintah di channel');

##### IRC Stuff. #####
while(<$sock>){
 chomp;
 $line   = $_;
 $backup = $line;
 $line   = lc($line);
 $countaway ++;

if($backup =~ m/^PING :(.*?)$/gi) {
   print $sock "PONG $1 \r\n";
}

if($backup =~ /Nickname is already in use/) {
   print $sock "NICK $nickalt\n";
}

if($line=~/376/){
   print $sock "JOIN $basechan \r\n";
 }

if($line=~/this nickname is registered and protected/){
   print $sock "PRIVMSG nickserv :identify $botpass\n";
   print $sock "MODE $botnick +B\n";
 }

if($line=~/^error :closing link:/){
  print "LOG: Connection has been closed, trying to reconnect!...\n";
  &connect;
 }

if($backup=~/^:(\S+)!(\S+)\@(\S+) PRIVMSG $botnick :\001VERSION\001.$/){
  print $sock "NOTICE $1 :\001VERSION ".&versi." $^V \001\n";
 }

if ($countaway == "100") {
   print $sock "AWAY ".&mylogo." [\037Uptime:\037 ".&uptime."] ".chr(187)." ".&away." ".chr(171)."\n";
   $countaway = 0;
}

### Chat ###
if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick .say (.*?).$/){
   print $sock "PRIVMSG $3 :$4\n";
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :.jo (.*?).$/){
   print $sock "JOIN $4\n";
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :.pa (.*?).$/){
   print $sock "PART $4\n";
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick .logo/){
   print $sock "PRIVMSG $3 :".&mylogo."\n";
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick off/){
   print $sock "NOTICE $admin :$notc TuRnInG oFF\n";
   my $shutdown = scramble_case('shutdown request by');
   print $sock "QUIT ".&mylogo." $shutdown \0030,1 $admin \003\n";
   exit();
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick jump/){
   print $sock "NOTICE $admin :$notc JuMPiNg tO ReStARt\n";
   my $restart = scramble_case('restart request by');
   print $sock "QUIT ".&mylogo." $restart \0030,1 $admin \003\n";
   sleep(2);
   &connect;
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick ver/){
   my $myos = `cat /etc/os-release|grep PRETTY_NAME`;
   my @sos = split( /=/, $myos);
   my $sos1 = $sos[1];
   my $ram=`cat /proc/meminfo |  grep "MemTotal"`;
   $ram =~ tr/0-9://dc;
   $sos1 =~ tr/0-9a-z A-Z\/\(\)//dc;
   my @ramz = split /:/, $ram;
   my $ramy = &sizeConversion($ramz[1]);
   print $sock "PRIVMSG $3 :$notc RunNInG wIth peRL $^V ".&mylogo."\n";
   print $sock "PRIVMSG $3 :$notc bOt rUn on \002$sos1\002 wIth RAM \002$ramy\002 MB\n";
   print $sock "PRIVMSG $3 :$notc LaUnCh bAckGroUNd Pid\002 $$\002\n";
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick .vo (.*?).$/){
   my $targetv = $3;
   my $nickv = $4;
   if ($targetv =~ /#/) {
        print $sock "MODE $targetv +v $nickv \r\n";
   } else {
        print $sock "PRIVMSG $admin :$notc $chanonly\n";
   }
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick .kick (.*?).$/){
   my $targetk = $3;
   my $nickk = $4;
   if ($targetk =~ /#/) {
        print $sock "KICK $targetk $nickk ".&mylogo." teNdanG!!\n";
   } else {
        print $sock "PRIVMSG $admin :$notc $chanonly\n";
   }
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick .kb (.*?).$/){
   my $targetb = $3;
   my $nickb = $4;
   if ($targetb =~ /#/) {
        print $sock "KICK $targetb $nickb ".&mylogo." OuT BaBE!!\n";
        print $sock "MODE $targetb +b $nickb\n";
   } else {
        print $sock "PRIVMSG $admin :$notc $chanonly\n";
   }
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick .op (.*?).$/){
   my $targeto = $3;
   my $nicko = $4;
   if ($targeto =~ /#/) {
        print $sock "MODE $targeto +o $nicko\n";
   } else {
        print $sock "PRIVMSG $admin :$notc $chanonly\n";
   }
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick .dv (.*?).$/){
   my $targetdv = $3;
   my $nickdv = $4;
   if ($targetdv =~ /#/) {
        print $sock "MODE $targetdv -v $nickdv\n";
   } else {
        print $sock "PRIVMSG $admin :$notc $chanonly\n";
   }
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick .do (.*?).$/){
   my $targetdo = $3;
   my $nickdo = $4;
   if ($targetdo =~ /#/) {
        print $sock "MODE $targetdo -o $nickdo\n";
   } else {
        print $sock "PRIVMSG $admin :$notc $chanonly\n";
   }
}

if($backup=~/^:$admin!(\S+)\@(\S+) PRIVMSG (\S+) :$botnick cycle/){
   if ($3 =~ /#/) {
        print $sock "PART $3 :".&mylogo." ".&cycle."\n";
        sleep(2);
        print $sock "JOIN $3 \r\n";
   } else {
        print $sock "PRIVMSG $admin :$notc $chanonly\n";
   }
}

} #end

sub away {
        my @aw = ( scramble_case('away from keyboard'),
                   scramble_case('bot juga manusia'),
                   scramble_case('nonton bioskop dolo'),
                   scramble_case('sarapan nasi goreng'),
                   scramble_case('dilarang ngintip yaa!'),
                   scramble_case('walking-walking sama dogie'),
                   scramble_case('sedang menyendiri dalam sepi'),
                   scramble_case('yang penting ngumpul'),
                   scramble_case('ngitung recehan saja')
        );
        my $aww = $aw[rand scalar @aw];
        return $aww;
}

sub versi {
        my $vver = scramble_case('jobot created by ijoo - running with perl');
        return $vver;
}

sub cycle {
        my @cw = ( scramble_case('cari inpaiter!'),
                   scramble_case('refreshing!'),
                   scramble_case('cycling!'),
                   scramble_case('out! and in!'),
                   scramble_case('looking!'),
                   scramble_case('tuing2x!'),
                   scramble_case('satpam!'),
                   scramble_case('rebound!'),
                   scramble_case('spam check!')
        );
        my $cww = $cw[rand scalar @cw];
        return $cww;
}

sub mylogo {
        my @bw = ("0","1","2","3","4","5","6","7","8","9","10","11","12");
        my $aco = $bw[rand scalar @bw];
        my $bco = $bw[rand scalar @bw];
        my $mylogo = "\003".$aco.",".$bco."C\003".$bco.",".$aco."\037o\037\003".$aco.",".$bco."V\003".$bco.",".$aco."I\003".$aco.",".$bco."D\003";
        return $mylogo;
}


sub uptime {
        my $etime = time();
        my $ctime = $etime - $utime;
        my $dtime = Time::Seconds->new( $ctime );
        return $dtime->pretty;
}

sub sizeConversion () {
    my $size = $_[0];
    my $oksize = ($size / 1024 );
    return ceil($oksize);
}
