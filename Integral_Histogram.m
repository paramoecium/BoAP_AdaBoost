function [Img_hist] = Integral_Histogram(Img_cell,Bin,Img_num)
% function to perform integral histogram
% Input:  Img_cell: in some specific feature space
% Input:  Img_num = 1 : perform general histogram
% Input:  Img_num = 2 : perform HoG
% Output: Img_hist: Integral histogram (cell)
Height = size(Img_cell{1,1},1);
Width = size(Img_cell{1,1},2);
Img_hist = cell(Height,Width);
% initialize:
for i = 1:Height
    for j = 1:Width
        Img_hist{i,j} = zeros(1,Bin);
    end
end
% end initialize
if Img_num == 1
    Img = Img_cell{1,1};
    for i = 1:Height
        for j = 1:Width
            if j ~= 1
                Img_hist{i,j} = hist(Img(i,j),0:Bin-1)+Img_hist{i,j-1};
            else
                Img_hist{i,j} = hist(Img(i,j),0:Bin-1);
            end
        end
    end
    for j = 1:Width
        for i = 1:Height
            if i ~= 1
                 Img_hist{i,j} = Img_hist{i,j}+Img_hist{i-1,j};
            else
                 Img_hist{i,j} = Img_hist{i,j};
            end
        end
    end
else
    % HoG: bin num 2, 4, 8
    magnit = Img_cell{1,1};
    angles = Img_cell{2,1};

    % ---------- bin num = 8 ---------- 
    if Bin == 8
        for i = 1:Height
            for j = 1:Width       
                if j ~= 1
                    Img_hist{i,j} = Img_hist{i,j-1};
                    bin_idx=0;
                    for ang_lim=-pi+2*pi/8:2*pi/8:pi
                        bin_idx = bin_idx+1;
                        if angles(i,j)<ang_lim
                            Img_hist{i,j}(bin_idx) = Img_hist{i,j}(bin_idx)+magnit(i,j);
                            break;
                        end
                    end % end for                
                else
                    bin_idx=0;
                    for ang_lim=-pi+2*pi/8:2*pi/8:pi
                        bin_idx = bin_idx+1;
                        if angles(i,j)<ang_lim
                            Img_hist{i,j}(bin_idx) = Img_hist{i,j}(bin_idx)+magnit(i,j);
                            break;
                        end
                    end % end for
                end
            end % end j
        end % end i
        
    % ---------- bin num = 4 ---------- 
    elseif Bin == 4
        for i = 1:Height
            for j = 1:Width       
                if j ~= 1
                    Img_hist{i,j} = Img_hist{i,j-1};
                    bin_idx=0;
                    for ang_lim=-pi+2*pi/8:2*pi/4:pi-2*pi/8
                        bin_idx = bin_idx+1;
                        if angles(i,j)<ang_lim
                            Img_hist{i,j}(bin_idx) = Img_hist{i,j}(bin_idx)+magnit(i,j);
                            break;
                        end
                    end % end for                
                else
                    bin_idx=0;
                    for ang_lim=-pi+2*pi/8:2*pi/4:pi-2*pi/8
                        bin_idx = bin_idx+1;
                        if angles(i,j)<ang_lim
                            Img_hist{i,j}(bin_idx) = Img_hist{i,j}(bin_idx)+magnit(i,j);
                            break;
                        end
                    end % end for
                end
            end % end j
        end % end i
        
    % ---------- bin num = 2 ---------- 
    elseif Bin == 2
        for i = 1:Height
            for j = 1:Width       
                if j ~= 1

                    Img_hist{i,j} = Img_hist{i,j-1};
                    
                    bin_idx=0;
                    for ang_lim=-pi+2*pi/8:2*pi/4:pi-2*pi/8
                        bin_idx = bin_idx+1;
                        if bin_idx == 3
                            bin_idx = 1;
                        end
                        if bin_idx == 4
                            bin_idx = 2;
                        end
                        if angles(i,j)<ang_lim
                            Img_hist{i,j}(bin_idx) = Img_hist{i,j}(bin_idx)+magnit(i,j);
                            break;
                        end
                    end % end for                
                else
                    bin_idx=0;
                    for ang_lim=-pi+2*pi/8:2*pi/4:pi-2*pi/8
                        bin_idx = bin_idx+1;
                        if bin_idx == 3
                            bin_idx = 1;
                        end
                        if bin_idx == 4
                            bin_idx = 2;
                        end
                        if angles(i,j)<ang_lim
                            Img_hist{i,j}(bin_idx) = Img_hist{i,j}(bin_idx)+magnit(i,j);
                            break;
                        end
                    end % end for
                end
            end % end j
        end % end i
        
    end % end different bin num
    
    for j = 1:Width
        for i = 1:Height
            if i ~= 1
                 Img_hist{i,j} = Img_hist{i,j}+Img_hist{i-1,j};
            else
                 Img_hist{i,j} = Img_hist{i,j};
            end
        end % end i
    end % end j
    
    % multiplied by 100! (may be modified after)
    for i = 1:Height
        for j = 1:Width
            Img_hist{i,j} = 100*Img_hist{i,j};
        end
    end
    
end % end if

end % end function