Click [here](https://github.com/ufukusubutun/Reordering_Switch#post-processing) to go back to the main readme page.

## Post-Processing

<img src="https://github.com/ufukusubutun/Reordering_Switch/blob/main/docs/plot.png"  width="35%" >


On the host where your data is/that you want to connect to:

	sudo apt update; sudo apt -y install python3-pip jupyter-core jupyter-client


Then install some Python libraries (add any extra libraries you'll need - pandas etc - to this list)

	python -m pip install --user jupyter-core jupyter-client jupyter_http_over_ws traitlets pandas matplotlib seaborn SciencePlots latex -U --force-reinstall

Some more packages needed for plotting with scienceplots IEEE format
	
	sudo apt -y install cm-super texlive texlive-latex-extra texlive-fonts-recommended dvipng


using `screen` migh come in handy

	PATH="$HOME/.local/bin:$PATH"
	jupyter serverextension enable --py jupyter_http_over_ws
	jupyter notebook   --NotebookApp.allow_origin='https://colab.research.google.com'   --port=8888   --NotebookApp.port_retries=0 --notebook-dir="" --no-browser --allow-root --NotebookApp.token='' --NotebookApp.disable_check_xsrf=True


	ssh -L 127.0.0.1:8888:127.0.0.1:8888 -o ServerAliveInterval=30 <YOUR_USERNAME>@<NODE_ID>.utah.cloudlab.us -i <YOUR_KEY_FILE>




Click [here](https://github.com/ufukusubutun/Reordering_Switch#post-processing) to go back to the main readme page.