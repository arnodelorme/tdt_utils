function [x, y] = plotortho(a, b, val, tmp); % val = 0 straight

m       = (a+b)/2;

if abs(a(1)-b(1)) < abs(a(2)-b(2))
    slope = (a(1)-b(1))/(a(2)-b(2));
    intersect = m(2)+slope*m(1);
    x = m(1)+val;
    y = -slope*x+intersect;
else
    slope = (a(2)-b(2))/(a(1)-b(1));
    intersect = m(1)+slope*m(2);
    y = m(2)+val;
    x = -slope*y+intersect;
end;

if nargin > 3
    %figure; 
    hold on;
    plot(a(1), a(2), 'r.'); hold on;
    plot(b(1), b(2), 'r.'); hold on;
    plot(x,y,'r.');
    axis equal
end;