function [BP, param] = design_beep(param)
param.fs = 44100;
param.td = 0.1;
param.fs_start = [432, 1296];
param.fs_end = [432, 1296]/2;
t = 0:1/param.fs:param.td;

BP.start = sum(sin(2*pi*t.*param.fs_start'));
BP.end = sum(sin(2*pi*t.*param.fs_end'));