function   fes = gen_fes(param, what)

switch what
    case "constant"
        fes_funct = @(fq, amp) @(t) square(2 * pi * fq * t)*amp;
        fes = fes_funct(param.fq , param.amp_max);
end

end