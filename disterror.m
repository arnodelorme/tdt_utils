function dist = disterror( val, ax, ay, bx, by, elecx, elecy);
    
    [cx cy] = plotortho([ax ay],[bx by], val);
    [arcx arcy] = plotarc([ax ay], [bx by], [cx cy]);
    
    alldist = zeros(size(arcx,1), length(elecx));

    arcx = repmat(arcx(:,1), [1 length(elecx)]);
    arcy = repmat(arcy(:,1), [1 length(elecy)]);
    elecx = repmat(elecx(:)', [size(arcx,1) 1]);
    elecy = repmat(elecy(:)', [size(arcy,1) 1]);

    alldist = sqrt((arcx-elecx).^2+(arcy-elecy).^2);
    %dist = (1-min(min(alldist)))*(abs(val)/10+1);
    dist = 1-min(min(alldist));
