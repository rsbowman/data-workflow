use "collections"

// Chandy-Misra solution to the dining philosophers problem in Pony
// R. Sean Bowman, July 2016

actor Philosopher
  // our name (for printing) and a stream to log info on
  let _name: String
  let _out: OutStream

  // how many times to eat
  var _how_hungry: U32

  // forks we need in order to eat
  let _missing_forks: Array[Philosopher] = Array[Philosopher]
  // forks we have already requested but not yet received
  let _requested_forks: Array[Philosopher] = Array[Philosopher]
  // forks we hold that are clean
  let _clean_forks: Array[Philosopher] = Array[Philosopher]
  // others waiting for us to finish with a fork
  let _waiting: Array[Philosopher] = Array[Philosopher]

  new create(name: String, how_hungry: U32, out: OutStream) =>
    _name = name
    _out = out
    _how_hungry = how_hungry

  fun ref log(msg: String) =>
    _out.print(_name + ": " + msg)

  fun ref _add_missing(missing: Philosopher) =>
    _missing_forks.push(missing)

  fun ref _remove_requested(missing: Philosopher) =>
    try
      _requested_forks.delete(_requested_forks.find(missing))
    else
      log("Couldn't remove requested fork!")
    end

  fun ref _can_eat(): Bool =>
    (_missing_forks.size() == 0) and (_requested_forks.size() == 0)

  fun ref eat() =>
    _clean_forks.clear()

    log("Eating! hunger " + _how_hungry.string())

    for i in Range(0, _waiting.size()) do
      try
        _waiting(i).receive_fork(this)
        _add_missing(_waiting(i))
      else
        log("COULDN'T SEND TO WAITING ")
      end
    end
    _waiting.clear()

    _how_hungry = _how_hungry - 1
    hunger()

  // initially we may be missing forks; this behavior says so
  be add_missing(missing: Philosopher) =>
    _add_missing(missing)

  // request a fork from the receiver
  be request_fork(requester: Philosopher) =>
    if _clean_forks.contains(requester) then
      _waiting.push(requester)
      log("queuing")
    else
      requester.receive_fork(this)
      _add_missing(requester)
      log("sending fork to ")
    end

  // receive a fork from another actor
  be receive_fork(giver: Philosopher) =>
    _remove_requested(giver)
    _clean_forks.push(giver)

    let num_missing = _missing_forks.size() + _requested_forks.size()
    log("received fork, missing " + num_missing.string())

    if _can_eat() then
      eat()
    else
      hunger()
    end

  // try to eat unless we've eaten enough times
  be hunger() =>
    if _how_hungry > 0 then
      if _can_eat() then
        eat()
      else
        if _missing_forks.size() > 0 then
          for missing in _missing_forks.values() do
            log("requesting fork")
            missing.request_fork(this)
            _requested_forks.push(missing)
          end
          _missing_forks.clear()
        end
      end
    end

actor Main
  new create(env: Env) =>
    let n_hungers: U32 = 8
    let out_stream = env.out

    let p1 = Philosopher("A", n_hungers, out_stream)
    let p2 = Philosopher("B", n_hungers, out_stream)
    let p3 = Philosopher("C", n_hungers, out_stream)
    let p4 = Philosopher("D", n_hungers, out_stream)
    let p5 = Philosopher("E", n_hungers, out_stream)

    // fork dependencies must form a DAG initially; p_1 holds both forks,
    // p_n holds neither, all others hold exactly one fork
    p2.add_missing(p1)
    p3.add_missing(p2)
    p4.add_missing(p3)
    p5.add_missing(p1)
    p5.add_missing(p4)

    let ps = [p2, p3, p1, p5, p4]
    for p in ps.values() do
      p.hunger()
    end
