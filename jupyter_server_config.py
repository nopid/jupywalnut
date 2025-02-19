c = get_config()  #noqa
c.ServerApp.allow_root = True
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.open_browser = False
c.ServerApp.iopub_data_rate_limit = 10000000
