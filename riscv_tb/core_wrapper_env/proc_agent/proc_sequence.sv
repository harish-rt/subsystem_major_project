class base_cpu_sequence extends uvm_sequence #(cpu_seq_item);
  `uvm_object_utils(base_cpu_sequence)

  cpu_seq_item  pkt;
  config_obj       obj;

  function new(string name = "base_cpu_sequence");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_full_name(), "=== Inside base_cpu_sequence body ===", UVM_MEDIUM)

    // Get Configuration Object
    if (!uvm_config_db#(config_obj)::get(null, "", "config_obj", obj))
      `uvm_fatal(get_type_name(), "config_obj not found")

    pkt = cpu_seq_item::type_id::create("pkt");

  endtask

endclass


