% EEGPLUGIN_TDT_UTIL() - EEGLAB plugin for computing and importing TDT
%                        files
% Usage:
%   >> eegplugin_tdt_util(fig, trystrs, catchstrs);
%
% Inputs:
%   fig        - [integer]  EEGLAB figure
%   trystrs    - [struct] "try" strings for menu callbacks.
%   catchstrs  - [struct] "catch" strings for menu callbacks.

function vers = eegplugin_tdt_util(fig, trystrs, catchstrs)

    vers = '1.0';
    if nargin < 3
        error('eegplugin_tdt_util requires 3 arguments');
    end
    
    % add folder to path
    % ------------------
    p = which('eegplugin_tdt_util.m');
    p = p(1:findstr(p,'eegplugin_tdt_util.m')-1);
    if ~exist('topo_tdt')
        addpath( p );
    end
    
    % find import data menu
    % ---------------------
    menui = findobj(fig, 'tag', 'tools');
    
    % menu callbacks
    % --------------
    com1 = [ trystrs.no_check 'LASTCOM = ''''; tdtreport(EEG);' catchstrs.add_to_hist ];
    com2 = [ trystrs.no_check 'LASTCOM = ''''; topo_neuroguidenew;'       catchstrs.add_to_hist ];
                
    % create menus
    % ------------
    tdt_m = uimenu( menui, 'label', 'Create/plot TDT files', 'separator', 'on');
    uimenu( tdt_m, 'label', 'Compute measures for TDT text files', 'callback', com1);
    uimenu( tdt_m, 'label', 'Plot measures from TDT text files'  , 'callback', com2);
