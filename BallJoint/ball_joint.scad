include<BOSL2/std.scad>
include<BOSL2/threading.scad>


part = "ball"; // ["ball", "cup", "cap", "lock"]
print_post = true;

$fn = 64;
$slop = .05;
pitch = INCH/20;
thread_dia = INCH * 0.25;
thread_len = 15;

t2_pitch = 2.5;
t2_starts = 3;

ball_dia = 20; 
cup_dia = ball_dia + 6;
cap_dia = ball_dia + 9;

if (part == "ball") ball();
if (part == "cup")  cup();
if (part == "cap")  cap();
if (part == "lock") lock();

module ball() {
    down(ball_dia/10)
    diff() {
        spheroid(d = ball_dia, anchor = BOT) {
            position(BOT) tag("remove") cyl(h = ball_dia/10, d = ball_dia, anchor = BOT);
            if (print_post) {
                position(TOP) down(2) threaded_rod(d=thread_dia, l=thread_len, pitch=pitch, 
                    $fa=1, $fs=1, end_len2=.5, bevel2=true, anchor = BOT);
            } else {
                position(TOP) tag("remove") threaded_rod(d=thread_dia, l=thread_len, pitch=pitch, 
                    $fa=1, $fs=1, end_len2=.1, bevel2=true, internal = true, anchor = TOP);

            }
        }
    }
}

module cup() {
    diff() {
       threaded_rod (d = cup_dia, h = ball_dia + 5, pitch = t2_pitch, starts = t2_starts, end_len1 = 15,
        bevel = true, $fa=1, $fs = 1, anchor = BOT) {
            position(TOP) tag("remove") spheroid(d = ball_dia + $slop);
            position(BOT) tag("remove") threaded_rod(d=thread_dia, l=9, 
                pitch=pitch, $fa=1, $fs=1, end_len1=.5, bevel1=true, internal = true, anchor = BOT);
        }
    }
}

module cap() {
    diff() {
        cyl(d = cap_dia, h = ball_dia *.75, rounding = 3, teardrop = true, anchor = BOT){
            position(BOT) up(ball_dia/4)  tag("remove") spheroid(d = ball_dia + $slop);          
            position(TOP) tag("remove") threaded_rod (d = cup_dia, h = ball_dia/2, 
                pitch = t2_pitch, end_len2 = 1, starts = t2_starts, bevel2 = true, internal = true, $fa=1, $fs = 1, anchor = TOP);
        }
    }
}

module lock() {
    diff() {
        cyl(d = ball_dia, h = thread_len/3, rounding = 1, teardrop = true, anchor = BOT);
        tag("remove")  threaded_rod(d=thread_dia, l=thread_len/3, pitch=pitch, 
            $fa=1, $fs=1, end_len=.5, bevel=true, internal = true, anchor = BOT);
        *down(pitch/2) tag("keep")  threaded_rod(d=thread_dia, l=thread_len, pitch=pitch, 
            $fa=1, $fs=1, end_len=.5, bevel=true, internal = false, anchor = BOT);
    }
}