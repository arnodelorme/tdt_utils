for theta = 0:10:350
    a = [ cos(theta/180*pi), sin(theta/180*pi) ];
    b = [ cos(theta/180*pi+pi), sin(theta/180*pi+pi) ];
    plotxy(a,b);
end;