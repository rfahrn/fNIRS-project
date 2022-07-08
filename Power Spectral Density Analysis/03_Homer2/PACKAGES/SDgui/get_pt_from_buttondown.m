function p = get_pt_from_buttondown(pos,optpos,axes_view)

switch lower(axes_view)
case {'xy', 'x-y'}
    p(1)=pos(1,1);
    p(2)=pos(1,2);
    p(3)=optpos(1,3);
case {'xz', 'x-z'}
    p(1)=pos(1,1);
    p(2)=optpos(1,2);
    p(3)=pos(1,3);
case {'yz', 'y-z'}
    p(1)=optpos(1,1);
    p(2)=pos(1,2);
    p(3)=pos(1,3);
end
