from metakernel import Magic
from metakernel.process_metakernel import ProcessMetaKernel
from metakernel.replwrap import REPLWrapper
from IPython.display import HTML
from pexpect import spawn
import os

HOME=os.environ['HOME']


class MyMagic(Magic):
    def line_showme(self, lapin):
        """
        %%showme LAPIN - display Result named lapin.gv
        """
        try:
            import pydot
        except:
            raise Exception("You need to install pydot")
        graph = pydot.graph_from_dot_file(f"{HOME}/Result/{str(lapin)}.gv")[0]
        svg = graph.create_svg()
        if hasattr(svg, "decode"):
            svg = svg.decode("utf-8")
        html = HTML(svg)
        self.kernel.Display(html)


class WalnutKernel(ProcessMetaKernel):
    # Identifiers:
    implementation = "Walnut"
    language = "walnut"
    language_info = {
        "mimetype": "text/x-walnut",
        "name": "walnutkernel",
        "language": "walnut",
        "file_extension": ".walnut",
    }

    _banner = "Da walnut à-la-main kernel"

    def __init__(self, *args, **kwargs):
        ProcessMetaKernel.__init__(self, *args, **kwargs)
        self.register_magics(MyMagic)

    def makeWrapper(self):
        child = spawn("java -jar /data/walnut.jar", cwd=HOME, echo=True, encoding="utf-8")
        child.expect(r"\n")
        return REPLWrapper(child, r"\[Walnut\]\$ ", None, echo=True)


if __name__ == "__main__":
    WalnutKernel.run_as_main()
