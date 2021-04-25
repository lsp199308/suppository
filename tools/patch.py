#!/usr/bin/env python3
# Created By MrDude
# Arm2Hex - https://armconverter.com/
 
import hashlib
import os.path
from pathlib import Path
import sys

compkip = "extracted/Loader.kip"
kipname = "extracted/Loader-dec.kip"

if not Path(kipname).exists():
    print("ERROR " + kipname + " does not exist.")
    sys.exit()

from bitstring import ConstBitStream
# Can initialise from files, bytes, etc.
s = ConstBitStream(filename=kipname)
find = s.find('0x01c0be121f00016b') # Atmosphere 13 > Current (set for 1 byte patch)
find2 = s.find('0x1F00016B48010054') # Atmosphere Future - mod when required (set for 4 bytes patch)

# Search to Start of Frame 0 code on byte boundary
def atmosnow():
    if find:
        res = int(''.join(map(str, find)))
        newval =  res / 8
        addpos = int(6) #byte position in find hex
        addpos2 =  int(256)
        final =  int(newval + addpos)
        final2 =  int(final - addpos2)
        print("\nIPS Offset patch address: 0x%X" % final)
    
        filename = (compkip)
        if not Path(filename).exists():
            print("ERROR " + filename + " does not exist.")
            sys.exit()
        
        if os.path.isfile(filename): 
            sha256_hash = hashlib.sha256()
            with open(filename,"rb") as f:
                # Read and update hash string value in blocks of 4K
                for byte_block in iter(lambda: f.read(4096),b""):
                    sha256_hash.update(byte_block)
                info = sha256_hash.hexdigest()   
                # print(info + ".ips")
                loader = ("[Loader:" + info[:-48] + "]")
                patchnfo = (".nosigchk=0:0x%X" % final2 + ":0x1:01,00")
                print("\nAdd to Patches.ini")
                print (loader)
                print(patchnfo)
                txt = open(info + ".txt", "w")
                txt.write(loader + "\n" + patchnfo)
                txt.close()
                
        
        # write ips patch
        ams_path = "../ams/atmosphere/kip_patches/loader_patches/"
        text_file = open(ams_path + info + ".ips", "wb")
        hexval = hex(final)
        shorthex =  hexval.replace("0x", "")
        y = bytes.fromhex(str("504154434800" + shorthex + "000100454F46")) #written ips patch
        text_file.write(y)
        text_file.close()
        os.remove(info + ".txt")
    
    else:
        atmosnext()

def atmosnext():
    if find2:
        res = int(''.join(map(str, find2)))
        newval =  res / 8
        addpos = int(4) #byte position in find2 hex
        addpos2 =  int(256)
        final =  int(newval + addpos)
        final2 =  int(final - addpos2)
        print("\nIPS Offset patch address: 0x%X" % final)
    
        filename = (compkip)
        if not Path(filename).exists():
            print("ERROR " + filename + " does not exist.")
            sys.exit()
        
        if os.path.isfile(filename): 
            sha256_hash = hashlib.sha256()
            with open(filename,"rb") as f:
                # Read and update hash string value in blocks of 4K
                for byte_block in iter(lambda: f.read(4096),b""):
                    sha256_hash.update(byte_block)
                info = sha256_hash.hexdigest()
                # print(info + ".ips")
                loader = ("[Loader:" + info[:-48] + "]")
                patchnfo = (".nosigchk=0:0x%X" % final2 + ":0x4:48010054,1F2003D5")
                print("\nAdd to Patches.ini")
                print (loader)
                print(patchnfo)
                txt = open(info + ".txt", "w")
                txt.write(loader + "\n" + patchnfo)
                txt.close()
        
        # write ips patch
        text_file = open(info + ".ips", "wb")
        hexval = hex(final)
        shorthex =  hexval.replace("0x", "")
        y = bytes.fromhex(str("504154434800" + shorthex + "00041F2003D5454F46")) #written ips patch
        text_file.write(y)
        text_file.close()
        os.remove(info + ".txt")        

    else:
        cantfind()

def cantfind():
    print ("Can't find the byte pattern, unable to create an ips file :-(")
    sys.exit()    
        
atmosnow()
