require 'json'

builds = JSON.load(STDIN.read)#["builds"]

$stderr.puts builds.size
data = builds#[0...68]

def sort_hash(hash)
  hash.map { |k,v|
    if Hash === v
      v = sort_hash(v)
    end
    [k, v]
  }.sort_by { |k,v| k }.to_h
end

data = data.map { |job|
  job = sort_hash(job)
  job.delete "build"
  job.delete "prelude"
  job.delete "run_benchs"
  # job["environment"] = sort_hash(job["environment"])
  job
}

puts JSON.pretty_generate(data)
