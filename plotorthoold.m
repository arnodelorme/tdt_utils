function [x y] = plotortho(a, b, tmp);

npoints = 50;
inc     = 0.2;
m       = (a+b)/2;

if abs(a(1)-b(1)) < abs(a(2)-b(2))
    slope = (a(1)-b(1))/(a(2)-b(2));
    intersect = m(2)+slope*m(1);
    x = linspace(m(1)-inc, m(1)+inc, npoints);
    y = -slope*x+intersect;
else
    slope = (a(2)-b(2))/(a(1)-b(1));
    intersect = m(1)+slope*m(2);
    y = linspace(m(2)-inc, m(2)+inc, npoints);
    x = -slope*y+intersect;
end;

if nargin > 2
    %figure; 
    hold on;
    plot(a(1), a(2), 'r.'); hold on;
    plot(b(1), b(2), 'r.'); hold on;
    plot(x,y,'b');
    axis equal
end;