-- Keep output nodes awake to avoid speaker pop/crackle and first-sound cutoff.
rule = {
  matches = {
    {
      { "node.name", "matches", "alsa_output.*" },
    },
  },
  apply_properties = {
    ["session.suspend-timeout-seconds"] = 0,
  },
}

table.insert(alsa_monitor.rules, rule)
