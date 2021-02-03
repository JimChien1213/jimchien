function y=kernel_sigm(x,xt,kappa,theta,alpha,yoffset)
y=[];
n=length(x);
for i=1:n
    %Beachte tanh(-x)
       k=tanh(kappa.*(-1*(x(i,1)+theta)))+yoffset;
       y=[y sum(alpha.*k)];
end
return