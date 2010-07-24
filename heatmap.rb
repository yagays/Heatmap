# -*- coding: utf-8 -*-
require "pp"
require 'optparse'

def open_t_delimited_file(filename)
  h = { }
  File.open(filename).readlines.each do |line|
    a =  line.split("\t")
    if h[a[0]]                      #もし既にidとfpkmの配列がhに入っている場合
      if h[a[0]].to_f < a[6].to_f   #既に入っているfpkmが新しいものより小さい場合は大きい方を取る(全体で見てそのid最大値が欲しい)
        h[a[0]] = a[6]
      end
    else                            #入っていない場合
      h[a[0]] = a[6]      
    end
  end
  puts filename.to_s + " was loaded."
  return h
end

def assoc_hash(a,id)
  if a[id]
    a_fpkm = a[id]
  else
    a_fpkm = "-"
  end
  return a_fpkm
end

def output_list(all_list,output_dir)
  if output_dir
    name = output_dir
  else
    name = "heatmap.txt"
  end
  f = File.open("#{name}","w")
  f.puts all_list
  f.close
  puts "output : " + name
end


if __FILE__ == $PROGRAM_NAME
  output_dir = nil
  fill_all = nil
  file_list = []
  id_list = []
  all_list = []
  name_list = ["gene_name"]
  
  ARGV.options do |opt|
    opt.on( '-a' ) { |a| fill_all =  1 }
    opt.on( '-o VAL' ) { |a| output_dir = a }
    opt.parse!()
  end
  ARGV.each do |arg|
    file_list <<  open_t_delimited_file(arg)
    name_list << File::basename(arg,".*")
  end
  all_list << name_list.join("\t")

  file_list.each do |h|
    id_list.concat(h.keys)
  end
  all_id = id_list.sort.uniq

  all_id.each do |id|
    tmp = [id]
    file_list.each do |f|
      tmp << assoc_hash(f,id)
    end
    if fill_all
      all_list << tmp.join("\t") unless tmp.index("-")
    else
      all_list << tmp.join("\t")
    end
  end
  
  output_list(all_list,output_dir)
end
