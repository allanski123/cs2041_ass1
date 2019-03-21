#!/usr/bin/perl -w

# Starting point for COMP[29]041 assignment 1
# http://www.cse.unsw.edu.au/~cs2041/assignments/pypl
# written by allan.lai@student.unsw.edu.au September 2017
# zid = z5117352 => Allan Lai

# subroutine to properly indent closing curly braces
# e.g. 
# while i < 10 { 
#     while j < 10 {
#         print("comp2041");
#     }    <---- places a curly closing brace if the previous line 
# }     <----    has a longer indent space (white space at the beginning)
sub close_indent {
    ($line, $indent_space, $len, $len_str, $initial_len) = @_;
    if ((length $indent_space) - $len > 4) {
        while($len != (length $indent_space)) {
            $line =~ s/(.*)/$len_str}\n$1/;
            $len_str =~ s/(.*)/$1    /;
            $indent_space =~ s/^ {4}//;
        }
        $indent_space = undef if $initial_len == 0;
    }
    elsif ($len < (length $indent_space)) {
        $line =~ s/(^ *)(.*)/$1}\n$1$2/;
        $indent_space =~ s/^ {4}//;
    } 
}

# global variable to assist with indenting
$indent_space = undef;

# read from a file, if no file is present read from STDIN
while ($line = <>) {
    chomp $line;
    # replace tabs with 4 spaces
    $line =~ s/\t/    /g;

    # replace #!/usr/bin/python3 with equivalent perl 
    if ($line =~ s{#!.*}{#!/usr/bin/perl -w}g) {
        print "$line\n";
        print "use POSIX 'floor';\n";
        next;
    }

    # skip blank lines that are not eof -> important for indenting
    next if ($line =~ /^ *$/ && !eof);  

    # credit for this line goes to user summer_cherry from the url below
    # http://www.unix.com/shell-programming-and-scripting/
    # 144294-need-perl-regular-expression-remove-comment.html
    # comments are captured in a variable and removed from the line for now    
    $comment = "";
    $comment = $1 if $line =~ s/( *#(?=[^'"]*$).*$)//;

    # if elsif below handles the len() method for
    # lists and strings that are not stored in variables
    # e.g len("comp2041") and len(["comp2041", "arrays"])
    if ($line =~ /\blen *\( *\[(.*?)\]/) {
        my $tmp = $1;
        my @arr_len = $tmp =~ /,/g;
        my $num = @arr_len;
        $num += 1 if $num != 0;
        $line =~ s/(\b)len *\( *\[.*?\] *\)/$1$num/;
    }
    elsif ($line =~ /\blen *\( *\"(.*?)\" *\)/) {
        my $tmp = length $1;
        $line =~ s/(\b)len *\( *\".*?\" *\)/$1$tmp/;
    }

    # stores python dict in a hash called dicts, 
    # which is later used to distinguish between types.
    if ($line =~ /([a-z][\w]*) *= *\{(.*)\}/) {
        my $name = $1;
        my $vals = $2;
        
        $vals =~ s/:/\=\>/g;
        $vals =~ s/(.*)/\($1\)/;

        $dicts{$name} = $vals;
    }

    # stores python lists in a hash called arrays
    if ($line =~ /([a-z][\w]*) *= *\[(.*)\]/) {
        my $name = $1;
        my $vals = $2;
        
        $arrays{$name} = $2;
        $line =~ s/\[($vals)\]/\($1\)/;
    }

    # handles assignment of variables
    if ($line =~ /([a-z][\w]*) *= *(.*)/) {
        my $var_name = $1;
        my $var_value = $2;

        # sequence of if statements to add the variable name to
        # its corresponding hash (arrays OR strings OR numbers OR dicts)
        # e.g. a = dict.keys() returns an array of key values
        # hence we add the variable name "a" to the arrays hash 
        if ($var_value =~ /([a-z][\w]*)\.keys\(\)/) {
            $arrays{$var_name} = 1;
        }
        if ($var_value =~ /\bsorted\b/) {
            $arrays{$var_name} = 1;
        }
        if ($arrays{$var_value}) {
            $arrays{$var_name} = $arrays{$var_value};
        }

        if ($line =~ s/sys\.stdin\.readlines\(\)/\<STDIN\>/) {
            $arrays{$var_name} = 1;
        }

        if ($strings{$var_value}) {
            $strings{$var_name} = 1;
        }
  
        if ($dicts{$var_value}) {
            $dicts{$var_name} = 1;
        }
 
        # check that the var_name is not already in arrays or dicts hash
        if (!$arrays{$var_name} && !$dicts{$var_name}) {
            # handles the returned value of sys.stdout.write("some_string")
            # e.g. num = sys.stdout.write("hello")  --> prints "hello", sets num = 5
            if ($var_value =~ /sys\.stdout\.write\("?(.*?)"?\)/) {
                my $str = $1;
                my $str_len = length $str;
                if ($strings{$str}) {
                    $str_len = (length $strings{$str}) - 2;
                    $line =~ s/(^ *)(.*)/$1print\("$str"\)\n$1$2;/;
                }
                else {
                    $line =~ s/(^ *)(.*)/$1print "$str"\n$1$2;/;
                }
                $numbers{$var_name} = $str_len;
                $var_value =~ s/(.*)/$str_len/;
                $line =~ s/sys\.stdout\.write\(.*?\)/$var_value/;
            } 
            else {   
                if ($var_value =~ /([\"\'][^\"\']+[\"\'].*)/) {
		    if ($var_value !~ /print.*\"/) {
	                $strings{$var_name} = $1;
	            }
		}
		$numbers{$var_name} = $1 if ($var_value =~ /(^[\w]+.*)/
		    && !$strings{$var_name});   
            }
        }
    }

    # iterate over strings hash, and foreach variable that occurs in $line,
    # add the appropriate perl sign $
    # string = "hello"
    # when $var is string -> replace all occurances of string in $line to $string
    # before: print(string)
    # after: print($string)
    # REPEAT this for every other hash, (arrays -> @, dicts -> %, numbers -> $)
    foreach $var (keys %strings) { 
        # handles concatenation of strings
        if ($line =~ /\b$var\b/ && $line =~ /\+/ && $line !~ /\bint\(.*?\)/) {
            $line =~ s/\+/\./g;
        } 
        
        # handles len() method for strings in variable names
        # e.g. string = "hello"
        # print(len(string))
        $line =~ s/\blen\($var\)/\(length $var\)/g;
        $line =~ s/\b$var\b/\$$var/g;

        # does not place $ in front of variable if it is inside double quotes.
        # e.g. var = "hello"
        # before: $line = print("var", var)
        # after: $line = print("var", $var)
        #                       ^^^ unchanged
        while ($line =~ /(\".*?)\$$var(.*?\")/) {
            $line =~ s/(\".*?)\$$var(.*?\")/$1$var$2/;
        }
    }

    foreach $var (keys %numbers) {
        # handles concatenation if int is cast to string.
        if ($line =~ /str *\($var/) {
            $line =~ s/\+/\./g;
        }

        $line =~ s/\b$var\b/\$$var/g;
        while ($line =~ /(\".*?)\$$var(.*?\")/) {
            $line =~ s/(\".*?)\\$$var(.*?\")/$1$var$2/;
        }
    }

    foreach $var (keys %arrays) {
        $line =~ s/\blen\($var\)/(scalar $var)/g;
        $line =~ s/\b$var\b/\@$var/g;
        $line =~ s/\@$var\[/\$$var\[/g;
        while ($line =~ /(\".*?)\@$var(.*?\")/) {
            $line =~ s/(\".*?)\@$var(.*?\")/$1$var$2/;
        }
    }

    foreach $var (keys %dicts) {
        $line =~ s/\(?$var\.keys\(\)\)?/\(keys $var\)/g; 
        $line =~ s/\b($var *= *)\{(.*)\}/$1$dicts{$var}/g;
        if ($line =~ s/\b$var\[(.*?)\]/\$$var\{$1\}/g) {
        
        } 
        else { 
            $line =~ s/\b$var\b/\%$var/g;
        }

        while ($line =~ /(\".*?)\%$var(.*?\")/) {
            $line =~ s/(\".*?)\%$var(.*?\")/$1$var$2/;
        } 
    }

    # handles print formatting with % operator
    #
    # e.g. print("$d $s" % 10, "years old")
    # output -> print("10 years old") 
    if ($line =~ /print *\( *\".*\%[(s|d|f)].* *\% *(.*)\)/) {
        my $vars = $1;
        my $tmp = "";
        my $tmp1 = "";

        # while matching variable or string
        # replace %[s|d|f] with the match
        # e.g. print("%d" % number)
        # replaces %d with $number -> print("$number")
        while ($vars =~ /([\@\$\%]?([\w]+[^,"'()\[\]]*)+)/g) {
            $tmp1 = $1;
            if ($tmp1 =~ /\bend\b/) {
                last;
            }
            $tmp = $tmp1;
            $line =~ s/\%[(s|d|f)]/$tmp1/;
        }

        # handles end = ''   
        if ($line =~ /\bend.*[\'\"](.*?)[\'\"]/) {
            my $end = $1;
            $line =~ s/\" *\%.*/$end\"\)/;
        }
        else {
            $line =~ s/ *\%.*/, "\\n")/;
        } 
        $line =~ s/ *\%.*/\)/; 
    }

    # appends the string in end='' to $line
    # e.g. print(lines[i], end='\n')
    # output: print(lines[i] . "\n")
    elsif ($line =~ /\bend.*[\'\"](.*?)[\'\"]/) {
        my $end = $1;
        $line =~ s/(print *\(.*?), *\$?end.*/$1 . "$end")/;
    } 
    
    # if the above two statements not executed, do a normal print
    # e.g. print(answer) 
    # output: print($answer, "\n") 
    else { 
        $line =~ s/print *\((.*)\)/print\($1, \"\\n\"\)/;
        $line =~ s/print *\(, (\"\\n\")\)/print $1/;
    }

    # replace sys.stdout.write with print statement
    # replace sys.stdin.readline with <STDIN>
    $line =~ s/sys\.stdout\.write\((.*)\)/print $1/;
    $line =~ s/\b[if][a-z]+\(sys\.stdin\.readline\(\)\)/\<STDIN\>/g;
    $line =~ s/sys\.stdin\.readline\(\)/\<STDIN\>/g;

    # handles the sorted() method with no optional args
    if ($line =~ /\bsorted *\((.*?)\)/) {
        my $var = $1;
        $var =~ s/\@//;
  
        # if trying to sort an array, first we need to determine 
        # the type of variables in it.
        if ($arrays{$var}) {
            my $arr_content = $arrays{$var};

            # if we find a string in the array, use normal perl sort()
            # and replace sorted() with sort()
            if ($arr_content =~ /[\"\'][a-z]/) {
                $line =~ s/\bsorted/sort/;
            }

            # otherwise, we are dealing with numbers are need to use 
            # sort {$a <=> $b} ()
            else {
                $line =~ s/\bsorted\((.*?)\)/sort\(\{\$a\<=\>\$b\} $1\)/g;
            }
        } 
        
        # if we are sorting a raw array like so
        # sorted(["coding", "an", "assignment"])
        # check if the contents are strings or numbers and replace sorted
        # accordingly..
        else {
            if ($var =~ /\[(.*?)\]/) {
                my $arr_content = $1;

                # if we match strings, do a normal translation sorted() to sort()
                if ($arr_content =~ /[\"\'].*?[\"\']/) {
                    $line =~ s/sorted\(\[(.*?)\]\)/sort\($1\)/;
                }
 
                # otherwise, use sort {$a <=> $b} () 
                else {
                    $line =~ s/sorted\(\[(.*?)\]\)/sort\(\{\$a \<=\> \$b\} \($1\)\)/;
                } 
            }
        }
    }  

    # append ; to the end of the line 
    # e.g. $line = print("hello")
    # after: $line = print("hello");
    if ($line !~ /^ *[(while|if|for|#|elif|else)]/) {
        $line =~ s/(.*)/$1;/; 
    }

    # change elif to elsif
    # break to last and continue to next
    # remove imports
    # change // to floor /
    # rm str() and float() casts
    # change sorted() to sort()
    $line =~ s/\belif\b/elsif/;
    $line =~ s/\bbreak\b/last/;
    $line =~ s/\bcontinue\b/next/;       
    $line =~ s.(\$?\w+) *\/\/ *(\$?\w+).floor \($1\/$2\).;
    $line =~ s/(float)\((.*?)\)/$2/g;
    $line =~ s/(str)\((.*?)\)/$2/g;
    $line =~ s/import .+//;
    $line =~ s/\bsorted\(/sort\(/g;

    # replace append() with push
    # e.g. list.append("string")  ->  push @list, "string"
    $line =~ s/(\@([a-z][\w]*))\.append\((.*?)\)/push $1, $3/;
    
    # handles pop() method with optional index parameter
    # e.g. list = [1, 4, 5]
    #      list.pop(0) removes 1 -> list now [4, 5]
    #      list.pop(0) removes 4 -> list now [5]
    #      list.pop() removes 5 -> list now []
    if ($line =~ /\@([a-z][\w]*)\.pop\((.*?)\)/) {
        my $arr_name = $1;
        my $const_arg = $2;
        if ($const_arg =~ /(\d+|\$)/) {
            $const_arg = "0 \- \(scalar \@$arr_name \- \($const_arg\)\)";     
            $line =~ s/(\@[a-z][\w]*)\.pop\(.*?\)/splice\($1, $const_arg, 1\)/; 
        }
        else {
            $line =~ s/(\@[a-z][\w]*)\.pop\((.*?)\)/splice\($1, -1, 1\)/;
        }
    }

    # handles indenting of while, for loops and if statements
    # a bit tedious as it uses global variables, but not too bad.
    if (defined $indent_space) {
        $line =~ /(^ *)/;
        $len_str = $1;
        $len = length $1;
 
        # if the indent space is not 4, increment until it is
        # this fixes poor indenting (e.g. indenting with 3 spaces)
        while ($len % 4 != 0) {
            $len += 1;
            $line =~ s/(.*)/ $1/;
        }
        $initial_len = $len;      
  
        # when we have reached the end of the file, we need to 
        # close the curly braces of while loops, for loops and if statements.
        # hence we call the close_indent routine
        if (eof && $len != 0 && $line !~ / *(while|if).*?: *[^ ]+/) {
            close_indent($line, $indent_space, $len, $len_str, $initial_len);

            print "$line$comment\n";
            $comment = ""; 
            $line = "";
            $len = 0;
            $len_str = "";
            $initial_len = $len; 
        }

        # we need to call this routine again to make sure all the braces are 
        # properly closed off
        close_indent($line, $indent_space, $len, $len_str, $initial_len);
    }

    # single line while and if statements handled by this 
    # firstly, append ; to end of line
    # then increment indent_space by 4
    # and finally separate the single line into multiple lines
    # and indent as needed. 
    if ($line =~ /( *)(while|if).*?: *[^ ]+/) {
        $line =~ s/(.*$)/$1;/;
        $indent_space .= "    ";
        $line =~ s/while *([^:]+)/while \($1\)/;
        $line =~ s/if *([^:]+)/if \($1\)/;
        $line =~ s/:/ \{/;
        $line =~ s/\{ */\{\n$indent_space/;
        $line =~ s/; */;\n$indent_space/g;
        $indent_space =~ s/^ {4}//; 
        $line =~ s/\n$indent_space    $/\n$indent_space\}/; 

        # if we are at the end of the file, we need to call close_indent again
        # to make sure curly braces are properly placed.
        # it seems odd to call this subroutine 3 times, but is necessary to
        # have fully functioning indenting (with no bugs)
        if (eof) {
            print "$line$comment\n";
            $comment = "";
            $line = "";
            $len = 0;
            $len_str = "";
            $initial_len = $len; 
            close_indent($line, $indent_space, $len, $len_str, $initial_len);
        }
    }

    # handles multi-line statements
    elsif ($line =~ /( *)(while|if|elsif|else) *(.*):/) {
        my $tmp = $1;
        my $tmp1 = $2;
        $line =~ s/$tmp1 *(.*):/$tmp1 \($1\) {/ if $tmp1 ne "else";
        $line =~ s/$tmp1:/$tmp1 {/ if $tmp1 eq "else";
   
        $indent_space = $tmp . "    ";
    }
   
    # handles multi-line for statements 
    # as they can use range() and differ to simpler while|if 
    # translations
    elsif ($line =~ /( *)for (\$?[\w]+) in (.*):/) {
        my $tmp = $2;
        my $tmp1 = $3;
        
        $indent_space = $1 . "    ";
        $tmp =~ s/^\$//;
        $numbers{$tmp} = 1;

        if ($tmp1 =~ /range/) {
            $tmp1 =~ s/range//;
            if ($tmp1 =~ s/\((.+), *(.+)\)/\($1\.\.$2\)/) {
                my $bound1 = $2 . " - 1";
                $tmp1 =~ s/\.\.(.*)/\.\.$bound1\)/;    
            }
            elsif ($tmp1 =~ /(^\(([^,]+)\)$)/) {
                my $bound2 = "0.." . $2 . " - 1";
                $tmp1 =~ s/(.*)/\($bound2\)/;
            }
        }
        else {
            $tmp1 =~ s/(.*)/\($1\)/;
        }
 
        $tmp1 =~ s/sys\.stdin/\(<STDIN>\)/;
        $line =~ s/for (.*) in (.*):/foreach \$$tmp $tmp1 {/; 
    }

    $line =~ s/(\n;|^;)//;

    # print translated line 
    print "$line$comment\n";
}
