for i = 1:192
X(i) = EEG.chanlocs(i).X;
end
for i = 1:192
Y(i) = EEG.chanlocs(i).Y;
end
for i = 1:192
Z(i) = EEG.chanlocs(i).Z;
end
figure;plot3(X,Y,Z,'bo')
axis equal
for i = 1:192
    text(X(i),Y(i),Z(i),num2str(i));
end
axis off