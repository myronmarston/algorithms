de Math

def a(n)
  exp = log(n)
  2 ** exp
end

def b(n)
  1
  #2 ** a(n)
end

def c(n)
  n ** (5.0/2)
end

def d(n)
  1
  #exp = n ** 2
  #2 ** exp
end

def e(n)
  (n ** 2) * log(n)
end

def pr(v)
  v.to_i.to_f.to_s.rjust(30)
end

1.upto(100) do |i|
  val = (2 ** i)
  puts ([val.to_s.rjust(10)] + [a(val), b(val), c(val), d(val), e(val)].map {|v| pr(v)}).join
end

