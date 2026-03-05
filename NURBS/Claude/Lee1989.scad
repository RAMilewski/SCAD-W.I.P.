/* The shape: a symmetric arch — two curved legs rising from [0,0],  and [31,0], , 
turning sharply through near-right-angle corners at the top, with a horizontal 
span across [11.4,30.6], →[19.6,30.6], . The data clustering near the corners is 
what makes it a stress test — the short dense chords right before and after 
the long sparse ones create exactly the parameterization challenges these 
papers are addressing. */

data = [
    [0.00,  0.00], [1.34,  5.00], [5.00,  8.66], [10.00, 10.00], [10.60, 10.40], [10.70, 12.00],
    [10.70, 28.60], [10.80, 30.20], [11.40, 30.60], [19.60, 30.60], [20.20, 30.20], [20.30, 28.60], 
    [20.30, 12.00], [20.40, 10.40], [21.00, 10.00], [26.00,  8.66], [29.66,  5.00], [31.00,  0.00]
];