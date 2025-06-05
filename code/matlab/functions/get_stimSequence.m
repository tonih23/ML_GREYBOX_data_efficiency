function seq = get_stimSequence(param)


r = 360/param.marker.ang_res;
c = param.marker.n/r;

m = reshape(1: param.marker.n, r,c);
m2 = [m;m;m]; %for circular jump

temp = [];
idx = 1;
for i = 1:size(m2(:),1)
    cr =  ceil(i/(r*3));
    cc = rem(i,(r*3));

    if cc ==0
        cc = r*3;
    end

    idx_list(1,:) = [cc-2, cr-2];
    idx_list(2,:) = [cc-2, cr];
    idx_list(3,:) = [cc-2, cr+2];
    idx_list(4,:) = [cc, cr-2];
    idx_list(5,:) = [cc, cr+2];
    idx_list(6,:) = [cc+2, cr-2];
    idx_list(7,:) = [cc+2, cr];
    idx_list(8,:) = [cc+2, cr+2];

    for j = 1:8
        idx_now = idx_list(j,:);
        if all(idx_now>0) && idx_now(1)<=r && idx_now(2)<=c

            temp(idx,1) = m2(i);
            temp(idx,2) = m2(idx_now(1),idx_now(2));
            idx = idx+1;

        end
    end
end

pairs1 = unique(sort(temp, 2), 'rows'); % Remove duplicate rows

[~, a] = sort(rand(size(pairs1,1),1));
pairs = pairs1(a,:);
% pairs = nchoosek(1:param.marker.n, 2);  % Generates all unique pairs


for i = 1:size(pairs,1)
    seq.anode{i} = pairs(i, 1);
    seq.cathode{i} = pairs(i, 2);
end

