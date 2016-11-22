function array = mysort(array, n)
for i=1:length(array(:, 1))
    for j=i+1:length(array(:, 1))
        if (cell2mat(array(i, n)) > cell2mat(array(j, n)))
            temp = array(i, :);
            for (x=1:length(temp))
                array(i, x) = array(j, x);
                array(j, x) = temp(x);
            end
        end
    end
end
end

