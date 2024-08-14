c = get_config()  #noqa
c.NotebookApp.allow_root = True
c.NotebookApp.ip = '0.0.0.0'
c.NotebookApp.open_browser = False
c.NotebookApp.iopub_data_rate_limit = 10000000
