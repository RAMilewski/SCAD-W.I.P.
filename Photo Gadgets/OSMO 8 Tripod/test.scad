font = "Cooper Black";
size = 40;
size2 = 30;
content = "EEN";
content2 = "Happy";
t1 = 1;
t2 = 3;
h = 3;
layer = 0.1;
n = ceil(h/layer);

// Functions to map a Z value 0..1 to an offset value 0..1.
rounded = function (z) sqrt(1-z*z);
bevel45 = function(z) 1-z;

module offset_extrude(h, r, n, f) {
    for (i = [1:n]) {
        linear_extrude(h/n*i) {
            // map 1:n to r:0
            thisR = r * f((i-1)/(n-1));
            offset(thisR)
            children();
        }
    }
}


offset_extrude(h=h, r=(t2-t1)/2, n=n, f=rounded) {
    translate([0, 0]) text(content2, font=font, size=size2, halign="center", valign="bottom", spacing=0.9);
    difference() {
        offset(t1/2) txt();
        offset(-t1/2) txt();
    }
}

module txt() {
    text(content, font=font, size=size, spacing=0.97, halign="center", valign="top");
}