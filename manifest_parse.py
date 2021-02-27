def qiime_manifest(directory, expression, output):
    '''
    generate a qiime manifest file from a directory of 16s data
    inputs:
        directory = where the 16s files are located, should be in fastq.gz format
        expression = regex expression of unique sample ids
        output = name of manifest file
    outputs:
        manifest csv in same directory as script
    '''
    import glob
    import pandas as pd
    import re

    directory = directory + "*.fastq.gz"
    filenames = glob.glob(directory)

    data = [] # empty list to fill, eventually make into DataFrame
    sample_id = []
    filepath =[]
    direction = []

    forward = "_R1_"
    reverse = "_R2_"

    for i in filenames: # sample ids
        sample_id.append(re.search(expression,i).group())

    for i in filenames: # read direction
        if forward in i:
            direction.append("forward")
        elif reverse in i:
            direction.append("reverse")

    data = [sample_id,filenames,direction] # combining lists
    df = pd.DataFrame(data).transpose() # need to transpose list of lists
    df.columns = ["sample-id","absolute-filepath","direction"]
    df.to_csv(output, index=False) #export

# qiime_manifest("/projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/sequences/round1/*/", "Paul[0-9]+.*S[0-9]+", "manifest_r1.csv")
# qiime_manifest("/projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/sequences/round2/*/", "Wells[0-9]+.*S[0-9]+", "manifest_r2.csv")
qiime_manifest("/projects/b1052/Wells_b1042/McKenna/s2ebpr_16s/sequences/round3/*/", "Sabba-[0-9]+.*S[0-9]+", "manifest_r3.csv")
