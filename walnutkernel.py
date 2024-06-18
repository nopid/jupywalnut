from metakernel import Magic
from metakernel.process_metakernel import ProcessMetaKernel
from metakernel.replwrap import REPLWrapper
from IPython.display import HTML
from pexpect import spawn
import os
from licofage.api import Study
from pathlib import Path as P

HOME=os.environ['HOME']

def genparentdir(fname):
        parent = fname.parent
        if not parent.is_dir():
            parent.mkdir(parents=True)
        return fname

class MyMagic(Magic):
    def line_showme(self, lapin):
        """
        %showme LAPIN - display Result named lapin.gv
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

    def line_DT(self, name, subst, bound=None):
        """
        %DT blop "a->ab, b->a"
        %DT blop "a->aba, b->b" 30
        %DT [name] [subst] [bound]

        Compute the Dumont-Thomas numeration system associated to
        the substitution "a->ab, b->a" with its addition. If not
        X-Pisot, a bound is needed.

        Generate a DFAO Blop for the fixpoint of the substitution
        and a numeration system ?msd_blop
        
        A script check_blop.txt is provided to check the addition.
        """
        try:
            if bound is not None:
                bound = [int(bound)]
            outdir = P(HOME)
            MSD = True
            endian = "msd_" if MSD else "lsd_"
            format = "Walnut"
            stud = Study(subst, True, True, True)
            dfao = P("Word Automata Library") / P(f"{name.title()}.txt")
            parent = P("Word Automata Library") / P(f"{name.title()}Parent.txt")
            numsys = P("Custom Bases") / P(f"{endian}{name}.txt")
            addition = P("Custom Bases") / P(f"{endian}{name}_addition.txt")
            check = P("Command Files") / P(f"check_{name}.txt")
            stud.gendfao(genparentdir(outdir / dfao), format)
            stud.genparentdfao(genparentdir(outdir / parent), format)
            stud.gennumsys(
                    genparentdir(outdir / numsys),
                    MSD,
                    format,
                    True,
                )
            (aa, b, fname) = ([1, 1, -1], 0, addition)
            stud.genlinear(
                    genparentdir(outdir / fname),
                    (aa, b),
                    MSD,
                    format,
                    True,
                    None,
                    None,
                    None,
                    bound,
                    False,
                )
            stud.gencheck(genparentdir(outdir / check), MSD, name)
            print("Done.")
        except ValueError as e:
            print(f"*** {str(e)}. Sorry!")
        except AssertionError as e:
            print(f"### {str(e)}. Sorry!")

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
        child = spawn("java -Xmx16g -jar /data/walnut.jar", cwd=HOME, echo=True, encoding="utf-8")
        child.expect(r"\n")
        return REPLWrapper(child, r"\[Walnut\]\$ ", None, echo=True)


if __name__ == "__main__":
    WalnutKernel.run_as_main()
