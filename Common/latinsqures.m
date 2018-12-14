function s = latinsq(n)

% Returns a latin sequare sequence.
% function s = latinsq(n)
% s will be a random latin square of size n, of the numerals 1..n

s = zeros(n);
s(1,:)=randperm(n);

for i=2:n
s(i,:)=s(i-1,:)+1;
end

s = mod(s,n)+1;

row = randperm(n);

for i=1:n-1
temp = s(i,:);
s(i,:)=s(row(i),:);
s(row(i),:)=temp;
end
