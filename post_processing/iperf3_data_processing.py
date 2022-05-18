#!/usr/bin/env python
# coding: utf-8

# In[87]:


import json
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import zipfile
import os
import math
import numpy.matlib
import pickle
mean = lambda l: sum(l) / len(l)

#%%


# 5_3_utah_delay_size_fixed
# probably garbage bc of the problem with bottleneck setting calculation
#file_loc = "/Users/ufukusubutun/Library/Mobile Documents/com~apple~CloudDocs/işler/6-21_around_rack/10-21_analytical_analysis/Conf-paper/resubmission_4_22/experiment_runs/5_3_utah_delay_size_fixed"
#fname = file_loc + '/' + 'comb_exp1-alg1-RTT4-N4-swcap1000-lam9.zip' 

# 5_5_utah_hopefully_fine   wait times not long enough for flow generation
#file_loc = "/Users/ufukusubutun/Library/Mobile Documents/com~apple~CloudDocs/işler/6-21_around_rack/10-21_analytical_analysis/Conf-paper/resubmission_4_22/experiment_runs/5_5_utah_hopefully_fine"

# 5_6_trial_of_random_wait_fix - random sender port num not implemented yet
#file_loc = "/Users/ufukusubutun/Library/Mobile Documents/com~apple~CloudDocs/işler/6-21_around_rack/10-21_analytical_analysis/Conf-paper/resubmission_4_22/experiment_runs/5_6_trial_of_random_wait_fix"

# 5_17
#file_loc = "/Users/ufukusubutun/Library/Mobile Documents/com~apple~CloudDocs/işler/6-21_around_rack/10-21_analytical_analysis/Conf-paper/resubmission_4_22/experiment_runs/5_17_aftercap_highcap"

# 5_17_omit fix
file_loc = "/Users/ufukusubutun/Library/Mobile Documents/com~apple~CloudDocs/işler/6-21_around_rack/10-21_analytical_analysis/Conf-paper/resubmission_4_22/experiment_runs/5_17_afteromit"




# list to store files
file_list = []
# Iterate directory
for file in os.listdir(file_loc):
    # check only text files
    if file.endswith('.zip'):
        file_list.append(file)
file_list.sort()
print(file_list)

exps = []
for name in file_list:
    params= {
                'trial': int(name[name.find('exp')+3:name.find('exp')+4]) ,
                'alg': int(name[name.find('alg')+3:name.find('alg')+4]) ,
                'RTT': int(name[name.find('RTT')+3:name.find('N')-1]   ),
                'N': int(name[name.find('N')+1:name.find('swcap')-1]),
                'sw_cap': int(name[name.find('swcap')+5:name.find('lam')-1]) , # 
                'lam': int(name[name.find('lam')+3:name.find('.')])
                #'mean_rtt': data['end']['streams'][0]['sender']['mean_rtt'], ### mean( [mean_rtt_0['sender']['mean_rtt'] for mean_rtt_0 in data['end']['streams'] ]  ) ###
                }
    exps.append(params)

# %%
flows = []
accepted_tot=0
rejected_tot=0



#This is as pythonic as you can get:

for f_name, exp_param in zip(file_list, exps):
    print(f_name, exp_param)


    with zipfile.ZipFile( file_loc + '/' + f_name, "r") as f:
        #print(f.namelist())
        accepted=0
        rejected=0
        for name in f.namelist():
            json_str = f.read(name).decode('UTF-8')
            #print( name, len(json_str))
            #print ( json_str[:5000] )
            
            try:
                data = json.loads( f.read(name).decode('UTF-8') )

                if data['start'].get('test_start') is not None:
                    #####print(( [mean_rtt_0['sender']['mean_rtt'] for mean_rtt_0 in data['end']['streams'] ]  ))
                    src_ip=data['start']['connected'][0]['local_host']
                    entry= {
                        'source': int(src_ip[ src_ip[:src_ip.rfind('.')].rfind('.') + 1 : src_ip.rfind('.') ]) -1 ,#int(data['start']['connected'][0]['local_host'][-3:-2]) - 1,
                        'destination': data['start']['connecting_to']['host'],
                        'payload': data['start']['test_start']['bytes'],
                        'retx': data['end']['sum_sent']['retransmits'],
                        'max_rtt': data['end']['streams'][0]['sender']['max_rtt'], # 
                        'min_rtt': data['end']['streams'][0]['sender']['min_rtt'],
                        'mean_rtt': data['end']['streams'][0]['sender']['mean_rtt'], ### mean( [mean_rtt_0['sender']['mean_rtt'] for mean_rtt_0 in data['end']['streams'] ]  ) ###
                        'send_tput': data['end']['sum_sent']['bits_per_second'],
                        'send_duration': data['end']['sum_sent']['seconds'],
                        'send_bytes': data['end']['sum_sent']['bytes'],
                        'recv_tput': data['end']['sum_received']['bits_per_second'],
                        'recv_duration': data['end']['sum_received']['seconds'],
                        'recv_bytes': data['end']['sum_received']['bytes']
                        }
                    entry.update( exp_param )
                    accepted += 1
                    flows.append(entry)
                else:
                    rejected += 1
            except Exception:
                print('error parsing', name)
                #rejected += 1
        print('accepted: ' ,accepted, ' \trejected: ', rejected)
        accepted_tot = accepted_tot + accepted
        rejected_tot = rejected_tot + rejected
            #print( data['end']['streams'][0]['sender']['retransmits'] )
            
            
            

        
print('accepted_tot: ' ,accepted, ' \trejected_tot: ', rejected)
print(flows[0:3])        
        

#%%


exp_results = pd.DataFrame(flows)


print(exp_results.head())


# %% pickle all variables
file = open(file_loc+'/exp_contents_pickle.data', 'wb')
# dump information to that file
pickle.dump(exp_results, file)
# close the file
file.close()

# %% load pickled variables
file = open(file_loc+'/exp_contents_pickle.data', 'rb')
# dump information to that file
exp_results = pickle.load(file)
# close the file
file.close()
print(exp_results.head())
  # %%

print(exp_results.columns)
useful = []
useful = exp_results[ exp_results['destination'] == 'sink' ]
useful.drop('destination', inplace=True, axis=1)
useful['gput'] = useful['recv_bytes']/useful['recv_duration']
useful['retx_norm'] = useful['retx']/(  (useful['recv_bytes'] > 1500)*useful['recv_bytes']/1500 + 1*((useful['recv_bytes'] <= 1500)) )
print(useful.head())
stats = useful.groupby(['alg', 'RTT', 'N', 'sw_cap', 'lam'])

stats_dur = stats['recv_duration'].agg(['mean', 'count', 'std'])
stats_gp = stats['gput'].agg(['mean', 'count', 'std'])
stats_retx = stats['retx_norm'].agg(['mean', 'count', 'std'])

# %%

# %%

alg_labels = ["RACK", "dupthresh", "dupACK"]

# %%




ci95_hi = []
ci95_lo = []
for i in stats_dur.index:
    m, c, s = stats_dur.loc[i]
    ci95_hi.append(m + 1.95*s/math.sqrt(c))
    ci95_lo.append(m - 1.95*s/math.sqrt(c))

stats_dur['ci95_hi'] = ci95_hi
stats_dur['ci95_lo'] = ci95_lo

ci95_hi_gp = []
ci95_lo_gp = []
for i in stats_gp.index:
    m, c, s = stats_gp.loc[i]
    ci95_hi_gp.append(m + 1.95*s/math.sqrt(c))
    ci95_lo_gp.append(m - 1.95*s/math.sqrt(c))

stats_gp['ci95_hi'] = ci95_hi_gp
stats_gp['ci95_lo'] = ci95_lo_gp


# retx
ci95_hi_retx = []
ci95_lo_retx = []
for i in stats_retx.index:
    m, c, s = stats_retx.loc[i]
    ci95_hi_retx.append(m + 1.95*s/math.sqrt(c))
    ci95_lo_retx.append(m - 1.95*s/math.sqrt(c))

stats_retx['ci95_hi'] = ci95_hi_retx
stats_retx['ci95_lo'] = ci95_lo_retx

'''
#reownd
ci95_hi_reownd = []
ci95_lo_reownd = []
for i in stats_reownd.index:
    m, c, s = stats_reownd.loc[i]
    ci95_hi_reownd.append(m + 1.95*s/math.sqrt(c))
    ci95_lo_reownd.append(m - 1.95*s/math.sqrt(c))

stats_reownd['ci95_hi'] = ci95_hi_reownd
stats_reownd['ci95_lo'] = ci95_lo_reownd

print(stats_tp)
'''
# %% for duration


N=1

data=[]

cap_vals=[100, 500,1000, 3000, 8000] # ,  3000 [500, 1000]
rtt_vals=[12] #,8] #4 #,3,5] #,10]#,100]  #  [5,25,50]
lam_vals=[5, 9] #5


plt.ioff()
fig=plt.figure()


#plt.rcParams['figure.dpi'] = 600
#plt.rcParams['savefig.dpi'] = 600
for lam_ind in range(len(lam_vals)):
    lns = []
    
    
    plt.subplot(len(lam_vals) , 1,  lam_ind+1) #3*lam_ind
    plt.grid(True, which="both")
    for rtt_ind in range(len(rtt_vals)):
        for i in [1,2,3]: #,3]: # ,2]: #,2,3]:#,3]: # range(1,4):
            dur_vals = np.array(stats_dur.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['mean'])
            #retx_vals = np.array(stats_retx.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['mean'])
            
            lolims= np.array(stats_dur.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['ci95_lo'])
            uplims= np.array(stats_dur.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['ci95_hi'])           
            
            colors=['tab:blue','tab:red',"tab:green"]
            linsyls=["solid","dotted","solid"]
            markers=['s','o','x']
            
            errors = np.array([uplims, lolims]) 
            rel_errors = errors * np.array([1,-1]).reshape(2,-1) + np.matlib.repmat(dur_vals, 2,1) * np.array([-1,1]).reshape(2,-1)
            
            #lns += plt.errorbar( np.array(cap_vals)/1e3, dur_vals/1e6, yerr=rel_errors/1e6, capsize=2 , color=colors[i-1], marker=markers[rtt_ind-1], markersize=6, linestyle=linsyls[i-1], fillstyle='none')
            lns += plt.errorbar( np.array(cap_vals)/1e3, dur_vals, yerr=rel_errors, capsize=2 , color=colors[i-1], marker=markers[i-1], markersize=6, linestyle=linsyls[i-1], fillstyle='none')       
            # *1e6*0.1*lam_vals[lam_ind]
        
#    plt.semilogx()
    plt.loglog()
    
##    plt.tight_layout()
    plt.title('λ = 0.'+str(lam_vals[lam_ind]))
    plt.ylim( (3e-2,2) )


    if lam_ind == 10:#0:
        plt.ylabel('Goodput (Mbps)')
        fig.axes[0].yaxis.set_label_coords(-.15, 0.5)
        #plt.xlabel('Emulated Switch Capacity (Gbps)')
        #plt.gca().xaxis.set_label_coords(.5,-.09)
        
        labs = ["RTT=1ms RACK", "RTT=1ms dupACK","RTT=3ms RACK", "RTT=3ms dupACK","RTT=5ms RACK", "RTT=5ms dupACK"]# [l.get_label() for l in lns]
        lns2=[]
        lns2.append(lns[0])
        lns2.append(lns[3])
        lns2.append(lns[6])
        lns2.append(lns[9])
        lns2.append(lns[12])
        lns2.append(lns[15])
        plt.legend(lns2, labs, loc="lower right",fontsize='xx-small')
        #print(lns)

#fig=plt.show()


plt.gcf().text(0.5, 0.01,' Switch Line Rate (Gbps)', fontsize=10, transform=fig.transFigure, ha='center')
plt.gcf().subplots_adjust(bottom=0.15)
plt.gcf().subplots_adjust(top=0.9) 
#fig.set_size_inches(5,2.4, forward=True)
fig.set_size_inches(5,6, forward=True)
plt.savefig('dur.pdf', dpi=600)
plt.close(fig)








# %% for goodput


N=1

data=[]

cap_vals=[100, 500,1000, 3000, 8000]  #[100, 500,1000, 2000, 3000] # ,  3000 [500, 1000]
rtt_vals=[4] #,8] #4 #,3,5] #,10]#,100]  #  [5,25,50]
lam_vals=[5, 9] #5


plt.ioff()
fig=plt.figure()


#plt.rcParams['figure.dpi'] = 600
#plt.rcParams['savefig.dpi'] = 600
for lam_ind in range(len(lam_vals)):
    lns = []
    
    
    plt.subplot(len(lam_vals) , 1,  lam_ind+1) #3*lam_ind
    plt.grid(True, which="both")
    for rtt_ind in range(len(rtt_vals)):
        for i in [1,2,3]: #,3]: # ,2]: #,2,3]:#,3]: # range(1,4):
            gp_vals = np.array(stats_gp.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['mean'])
            #retx_vals = np.array(stats_retx.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['mean'])
            
            lolims= np.array(stats_gp.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['ci95_lo'])
            uplims= np.array(stats_gp.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['ci95_hi'])           
            
            colors=['tab:blue','tab:red',"tab:green"]
            linsyls=["solid","dotted","solid"]
            markers=['s','o','x']
            
            errors = np.array([uplims, lolims]) 
            rel_errors = errors * np.array([1,-1]).reshape(2,-1) + np.matlib.repmat(gp_vals, 2,1) * np.array([-1,1]).reshape(2,-1)
            
            #lns += plt.errorbar( np.array(cap_vals)/1e3, dur_vals/1e6, yerr=rel_errors/1e6, capsize=2 , color=colors[i-1], marker=markers[rtt_ind-1], markersize=6, linestyle=linsyls[i-1], fillstyle='none')
            lns += plt.errorbar( np.array(cap_vals)/1e3, gp_vals, yerr=rel_errors, capsize=2 , color=colors[i-1], marker=markers[i-1], markersize=6, linestyle=linsyls[i-1], fillstyle='none')       
            # *1e6*0.1*lam_vals[lam_ind]
        
#    plt.semilogx()
    plt.loglog()
    
##    plt.tight_layout()
    plt.title('λ = 0.'+str(lam_vals[lam_ind]))
#    plt.ylim( (0,1) )


    if lam_ind == 10:#0:
        plt.ylabel('Goodput (Mbps)')
        fig.axes[0].yaxis.set_label_coords(-.15, 0.5)
        #plt.xlabel('Emulated Switch Capacity (Gbps)')
        #plt.gca().xaxis.set_label_coords(.5,-.09)
        
        labs = ["RTT=1ms RACK", "RTT=1ms dupACK","RTT=3ms RACK", "RTT=3ms dupACK","RTT=5ms RACK", "RTT=5ms dupACK"]# [l.get_label() for l in lns]
        lns2=[]
        lns2.append(lns[0])
        lns2.append(lns[3])
        lns2.append(lns[6])
        lns2.append(lns[9])
        lns2.append(lns[12])
        lns2.append(lns[15])
        plt.legend(lns2, labs, loc="lower right",fontsize='xx-small')
        #print(lns)

#fig=plt.show()


plt.gcf().text(0.5, 0.01,' Switch Line Rate (Gbps)', fontsize=10, transform=fig.transFigure, ha='center')
plt.gcf().subplots_adjust(bottom=0.15)
plt.gcf().subplots_adjust(top=0.9) 
#fig.set_size_inches(5,2.4, forward=True)
fig.set_size_inches(5,6, forward=True)
plt.savefig('gp.pdf', dpi=600)
plt.close(fig)





# %% for ReTX


N=1

data=[]

cap_vals=[100, 500,1000, 3000, 8000] #[100, 500,1000, 2000, 3000] # ,  3000 [500, 1000]
rtt_vals=[4] #,8] #4 #,3,5] #,10]#,100]  #  [5,25,50]
lam_vals=[5, 9] #5

plt.ioff()
fig=plt.figure()


#plt.rcParams['figure.dpi'] = 600
#plt.rcParams['savefig.dpi'] = 600
for lam_ind in range(len(lam_vals)):
    lns = []
    
    
    plt.subplot(len(lam_vals) , 1,  lam_ind+1) #3*lam_ind
    plt.grid(True, which="both")
    for rtt_ind in range(len(rtt_vals)):
        for i in [1,2,3]: #,3]: # ,2]: #,2,3]:#,3]: # range(1,4):
            retx_vals = np.array(stats_retx.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['mean']) / np.array(stats_retx.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['count'])
            #retx_vals = np.array(stats_retx.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['mean'])
            
            lolims= np.array(stats_retx.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['ci95_lo'])
            uplims= np.array(stats_retx.loc[i].loc[rtt_vals[rtt_ind]].loc[N].xs(lam_vals[lam_ind], level='lam')['ci95_hi'])           
            
            colors=['tab:blue','tab:red',"tab:green"]
            linsyls=["solid","dotted","solid"]
            markers=['s','o','x']
            
            errors = np.array([uplims, lolims]) 
            rel_errors = errors * np.array([1,-1]).reshape(2,-1) + np.matlib.repmat(retx_vals, 2,1) * np.array([-1,1]).reshape(2,-1)
            
            #lns += plt.errorbar( np.array(cap_vals)/1e3, dur_vals/1e6, yerr=rel_errors/1e6, capsize=2 , color=colors[i-1], marker=markers[rtt_ind-1], markersize=6, linestyle=linsyls[i-1], fillstyle='none')
            ####lns += plt.errorbar( np.array(cap_vals)/1e3, retx_vals, yerr=rel_errors, capsize=2 , color=colors[i-1], marker=markers[i-1], markersize=6, linestyle=linsyls[i-1], fillstyle='none')
            lns += plt.plot( np.array(cap_vals)/1e3, retx_vals, color=colors[i-1], marker=markers[i-1], markersize=6, linestyle=linsyls[i-1], fillstyle='none')
            # *1e6*0.1*lam_vals[lam_ind]
        
#    plt.semilogx()
    plt.loglog()
    
##    plt.tight_layout()
    plt.title('λ = 0.'+str(lam_vals[lam_ind]))
    #plt.ylim( (2e-5,1e-3) )


    if lam_ind == 10:#0:
        plt.ylabel('Goodput (Mbps)')
        fig.axes[0].yaxis.set_label_coords(-.15, 0.5)
        #plt.xlabel('Emulated Switch Capacity (Gbps)')
        #plt.gca().xaxis.set_label_coords(.5,-.09)
        
        labs = ["RTT=1ms RACK", "RTT=1ms dupACK","RTT=3ms RACK", "RTT=3ms dupACK","RTT=5ms RACK", "RTT=5ms dupACK"]# [l.get_label() for l in lns]
        lns2=[]
        lns2.append(lns[0])
        lns2.append(lns[3])
        lns2.append(lns[6])
        lns2.append(lns[9])
        lns2.append(lns[12])
        lns2.append(lns[15])
        plt.legend(lns2, labs, loc="lower right",fontsize='xx-small')
        #print(lns)

#fig=plt.show()


plt.gcf().text(0.5, 0.01,' Switch Line Rate (Gbps)', fontsize=10, transform=fig.transFigure, ha='center')
plt.gcf().subplots_adjust(bottom=0.15)
plt.gcf().subplots_adjust(top=0.9) 
#fig.set_size_inches(5,2.4, forward=True)
fig.set_size_inches(5,6, forward=True)
plt.savefig('retx.pdf', dpi=600)
plt.close(fig)






# %% cdf comparison of non aggregated data





 #%%

tput=df[df['destination']=='sink'].recv_tput
g = sns.ecdfplot(tput);
#g.hold()
g.set(xscale="log");
print('mean:', np.mean(tput)*1e-6, ' Mbps')

#%%

duration=df[ (df['destination']=='sink') ].recv_duration #  &  (df['recv_tput']!=0)
g = sns.ecdfplot(duration);
#g.hold()
g.set(xscale="log");
print('mean:', np.mean(duration), ' sec')




# In[123]:


f = open('comb_exp1-alg2-RTT1-N4-swcap1000-lam9/all_merged.json') #'comb_exp1-alg2-RTT1-N1-swcap100-lam9.json')
data = json.load(f)


# In[124]:


type(data)
data[0][570]


# In[125]:


data[0][0]['start']['connecting_to']['host'] # destination


# In[126]:


data[0][0]['start']['test_start']['bytes'] # payload size in bytes


# In[127]:


data[0][0]['end']['streams'][0]['sender']['retransmits'] # # of retx


# In[128]:


data[0][0]['end']['streams'][0]['sender']['max_rtt'] # max rtt in us
data[0][0]['end']['streams'][0]['sender']['min_rtt'] # min rtt in us
data[0][0]['end']['streams'][0]['sender']['mean_rtt'] # mean rtt in us


# In[129]:


data[0][0]['end']['streams'][0]['receiver']['bits_per_second'] # recv thruput
data[0][0]['end']['streams'][0]['receiver']['seconds'] # recv duration


# In[130]:


data[0][0]['end']


# In[131]:


flows = []
accepted=0
rejected=0
for nodes in data:
    for f in nodes:
        if f['start'].get('test_start') is not None:
            entry= {
                'destination': f['start']['connecting_to']['host'],
                'payload': f['start']['test_start']['bytes'],
                'retx': f['end']['streams'][0]['sender']['retransmits'],
                'max_rtt': f['end']['streams'][0]['sender']['max_rtt'],
                'min_rtt': f['end']['streams'][0]['sender']['min_rtt'],
                'mean_rtt': f['end']['streams'][0]['sender']['mean_rtt'],
                'recv_tput': f['end']['streams'][0]['receiver']['bits_per_second'],
                'recv_duration': f['end']['streams'][0]['receiver']['seconds']
                }
            accepted += 1
            flows.append(entry)
        else:
            rejected += 1

print('accepted: ' ,accepted, ' \trejected: ', rejected)
'''
print( f['start'])
entry= {
    'destination': f['start']['connecting_to']['host'],
    'payload': None,
    'retx': None,
    'max_rtt': None,
    'min_rtt': None,
    'mean_rtt': None,
    'recv_tput': None,
    'recv_duration': None
    }
'''
print(flows[0:3])


# In[132]:


df = pd.DataFrame(flows)


# In[133]:


df.head()


# In[134]:


#df['end'][0]['sum_received']['bits_per_second']


# %%

tput=exp_results[exp_results['destination']=='sink'].send_bytes
g = sns.ecdfplot(tput);
#g.hold()
g.set(xscale="log");
#print('mean:', np.mean(tput)*1e-6, ' Mbps')
plt.show()

# %%

tput=exp_results[exp_results['destination']=='sink'].recv_bytes
g = sns.ecdfplot(tput);
#g.hold()
#g.set(xscale="log");
#print('mean:', np.mean(tput)*1e-6, ' Mbps')
plt.show()



# In[135]:


tput=exp_results[exp_results['destination']=='sink'].recv_tput
g = sns.ecdfplot(tput);
#g.hold()
g.set(xscale="log");
print('mean:', np.mean(tput)*1e-6, ' Mbps')
plt.show()


# In[138]:


duration=exp_results[exp_results['destination']=='sink'].recv_duration
g = sns.ecdfplot(duration);
#g.hold()
g.set(xscale="log");
print('mean:', np.mean(duration), ' sec')
plt.show()


# In[136]:


mean_rtt=exp_results[exp_results['destination']=='sink'].mean_rtt*1e-3
g = sns.ecdfplot(mean_rtt);
g.set(xscale="log");
print('mean rtt:', np.mean(mean_rtt), ' ms')
plt.show()


# In[137]:


retx=exp_results[exp_results['destination']=='sink'].retx
g = sns.ecdfplot(retx);
#g.hold()
g.set(xscale="log");
print('retx:', np.mean(retx))
plt.show()

# In[ ]:




