function [] = sab_09_hedges_g(condition, ylims_im, ylims_time)
    % e.g.
    %
    % sab_09_hedges_g.m--
    %
    % Input arguments:
    %
    % Output arguments:
    %
    % Other m-files required:
    %
    % Example usage:
    %
    %
    % Developed in Matlab 9.3.0.948333 (R2017b) Update 9 on PCWIN64
    % at University of Oldenburg.
    % Sarah Blum (sarah.blum@uol.de), 2019-09-06 09:38
    %-------------------------------------------------------------------------
    

    % path info
    PATHIN = ['data/epoched/', condition];
    
    % cap data list
    flist_freq_cap = dir([PATHIN, '*cap_freq.set']);
    flist_rare_cap = dir([PATHIN, '*cap_rare.set']);
    
    % feegrid data list
    flist_freq_grid = dir([PATHIN, '*grid_freq.set']);
    flist_rare_grid = dir([PATHIN, '*grid_rare.set']);
    
    LISTS = {flist_freq_cap, flist_rare_cap, flist_freq_grid, flist_rare_grid};
    
    % indices to store the ERP
    cf = 1; ,cr = 1; gf = 1; gr = 1;
    
    % for all subjects
    for s = 1 : 20
        % and all conditions
        for li = 1 : length(LISTS)
            
            % load one subject, one electrode setup (cap,grid) and one condition (freq,rare)
            EEG = pop_loadset('filename',LISTS{li}(s).name,'filepath', [PATHIN]);
            
            % store the averaged ERP for this subject
            switch li
                case 1 % flist_freq_cap
                    ERP_cap_freq(cf,:,:) = mean(EEG.data,3);
                    cf = cf + 1;
                case 2 % flist_rare_cap
                    ERP_cap_rare(cr,:,:) = mean(EEG.data,3);
                    cr = cr + 1;
                case 3 % flist_freq_grid
                    ERP_grid_freq(gf,:,:) = mean(EEG.data,3);
                    gf = gf + 1;
                case 4 % flist_rare_grid
                    ERP_grid_rare(gr,:,:) = mean(EEG.data,3);
                    gr = gr + 1;
            end
            % after this, ERP_* contain 20x24x500: 20 subj, 24 channels (or 22) and 500 samples
            % for the comparison of effect size, we want all averaged ERPs in the method, not the grand average,
            % so the structure is good now
        end
    end
    
    % do the comparison and indicate with 'isDep' that the compared data are dependent (paired) --> this
    % is in this form a repeated measures design
    for ch = 1: 24 % cap has 24 channels
        for sample = 1: 500
            stats = mes(ERP_cap_freq(:,ch,sample), ERP_cap_rare(:,ch,sample),  'hedgesg', 'isDep',1 );
            hg_cap(ch,sample) = stats.hedgesg;
        end
    end
    
    for ch = 1: 22 % grid has 22 channels
        for sample = 1: 500
            stats = mes(ERP_grid_freq(:,ch,sample), ERP_grid_rare(:,ch,sample),  'hedgesg', 'isDep',1 );
            hg_grid(ch,sample) = stats.hedgesg;
        end
    end
    
    HG = {hg_grid, hg_cap};
     % figure things
    figure('rend', 'painters', 'units', 'centimeters', 'pos', [1,1,18,18], 'name', condition(1:9));
    supertitle(condition(1:9));
     % plot channels in logical order: lateral/side channels, then center/centrall, then side again
    CHAN_ORDER = {[11:-1:1, 12:1:22], [1:24]};
    NAMES = {'Fp1','Fp2','Fz','F7','F8','Fc1','Fc2','Cz','C3','C4',...
        'T7','T8','CPz','Cp1','CP2','CP5','CP6','Tp9','Tp10','Pz','P3','P4','O1','O2'};
    TICKS = {{['  left'], '', '              center', [ ' right ']}, NAMES};
        %{['  frontal'], '', '           central', [' occipital ']}};
       
    TITLES = {'fEEGrid', 'Cap'};
    
    for cond = 1 : 2
        
        % image of effect size
        h1 = subplot(2,2,cond);
        ims = imagesc(abs(HG{cond}(CHAN_ORDER{cond},:)));
        title(TITLES{cond});
        caxis(ylims_im)
        % adapt y axis
        oldTicks = ims.Parent.YTick;
        newTicks = TICKS{cond};
        set(gca,'TickLabelInterpreter', 'tex', ...
            'YTickLabel', newTicks, ...
            'YTickLabelRotation', 90);
        if mod(cond,2) ~= 0
            ylabel('Channels');
        end
        
        % adapt x labels
        oldTicks = ims.Parent.XTick;
        newTicks = EEG.times(oldTicks);
        set(gca,'XTickLabel', newTicks+2)
        %xlabel('Time [ms]');
        axis square
        % save original size without colorbar for the current axes
        originalSize1 = get(gca, 'Position');
        
        % add and adapt colorbar
        c = colorbar('southoutside');
        c.LineWidth = 0.25;

        % plot of effect size
        h2 = subplot(2,2,cond+2);
        plot(EEG.times, abs(HG{cond})', 'k', 'LineWidth', 0.5);
        axis tight
        hold on
        hline(0.8, 'r')
        axis square
       
        % put ylabel only on left plot
        if mod(cond,2) ~= 0
            ylabel('Hedges G');
        end
        
        xlabel('Time [ms]')
        ylim(ylims_time);
        originalSize2 = get(gca, 'Position');
        
        % resize images because of colorbar
        set(h1, 'Position', originalSize1);
        set(h2, 'Position', originalSize2);
        set(gca, 'FontName', 'Sans serif')
    end
    
    % resize all fonts
    set(findall(gcf,'-property','FontSize'),'FontSize',12);
    set(findall(gcf,'-property','FontName'),'FontName', 'Sans serif');
    set(gcf, 'Color', 'white')

    
    % for the paper: we want to report some max hedge's g values (perhaps)
    [val_grid, ~] = max(abs(HG{1})');
    [max_value, val_index] = maxk(val_grid, 5)
    
    
    [val_cap, ~] = max(abs(HG{2})');
    [max_value, val_index] = maxk(val_cap, 5)
    
    
end

