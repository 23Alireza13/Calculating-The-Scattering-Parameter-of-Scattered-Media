clc;
clear all;
close all;

image=myimage("Sample50_IL7_040.bmp");
image.edge_detection(1, "Sobel");