import argparse
import os
import random

parser = argparse.ArgumentParser(description='Performs random sampling of Raw files')
parser.add_argument("-rawfile_path", type=str, help='Path to a directory where raw files are stored')
parser.add_argument("-sample_size", type=int, help='Number of raw files to be considered')
parser.add_argument("-seed", type=int, help='Set the seed for reproducibility')
    
args = parser.parse_args()

def parse_rawfiles(directory):
    # Get a list of all files in the directory
    if not os.path.isdir(directory):
        raise ValueError(f"{directory} is not a valid directory.")
    	
    rawfile_types = {"raw":"Thermo","wiff":"Sciex","mzML":"Open Source","d":"Bruker"}
    rawfiles = []
    for f in os.listdir(directory):
        if os.path.isfile(os.path.join(directory, f)):
            if f.split(".")[-1] in rawfile_types:
                rawfiles.append(os.path.join(directory, f))
        
        if os.path.isdir(os.path.join(directory, f)):
            if f.split(".")[-1] in rawfile_types:
                rawfiles.append(os.path.join(directory, f))
    
    return rawfiles
		
def random_file_sampling(directory, sample_size, seed=None):

    '''
    Randomly samples files from a specified directory.
    
    Args:
    directory (str): Path to the directory containing files to sample.
    sample_size (int): Number of files to sample.
    seed (int, optional): Seed for random number generator to ensure reproducibility.
    
    Returns:
    list: A list of randomly sampled file paths.
    '''

    print (directory)
    # Get a list of all files in the directory
    if not os.path.isdir(directory):
        raise ValueError(f"{directory} is not a valid directory.")
    else:
        rawfiles = parse_rawfiles(directory)
    
    # Ensure sample_size is not greater than the number of available files
    if sample_size > len(rawfiles):
        raise ValueError(f"Sample size {sample_size} is larger than the number of available files ({len(rawfiles)}).")
    	
    # Set seed for reproducibility, if provided
    if seed is not None:
        random.seed(seed)
    	
    # Perform random sampling
    sampled_files = random.sample(rawfiles, sample_size)
    
    return sampled_files

if __name__ == "__main__":

    random_rawfiles = random_file_sampling(args.rawfile_path, args.sample_size, args.seed)
    
    outfile = "Rawfiles_for_library.tsv"
    with open(outfile, "w") as outf:
        outf.writelines(i + "\n" for i in random_rawfiles)
