function  s = addstruct(s,d)
%% concatenate the structured arrays
f = fieldnames(d);
if isempty(s)
    s = d;
else
    for i = 1:length(f)
        s.(f{i}) = [s.(f{i});d.(f{i})];
    end
end
end
