using Javis, JavisNB, Test, Interact

function ground(args...)
    Javis.background("white")
    sethue("black")
end


@testset "Global Tests" begin
    @testset "Pluto Viewer" begin
        v = JavisNB.PlutoViewer("foo.png")
        astar(args...; do_action = :stroke) = star(O, 50, 5, 0.5, 0, do_action)
        acirc(args...; do_action = :stroke) = circle(Point(100, 100), 50, do_action)

        vid = Video(500, 500)
        back = Background(1:100, ground)
        star_obj = Object(1:100, astar)
        act!(star_obj, Action(morph_to(acirc; do_action = :fill)))

        l1 = @JLayer 20:60 100 100 Point(0, 0) begin
            obj = Object((args...) -> circle(O, 25, :fill))
            act!(obj, Action(1:20, appear(:fade)))
        end

        objects = vid.objects
        all_objects = [vid.objects..., Javis.flatten(vid.layers)...]
        frames = Javis.preprocess_frames!(all_objects)

        @test v.filename === "foo.png"
        img = JavisNB._pluto_viewer(vid, length(frames), objects)
        for i in 1:length(img)
            @test img[i] == Javis.get_javis_frame(vid, objects, i, layers = [l1])
        end
    end

    @testset "Jupyter Viewer" begin
        astar(args...; do_action = :stroke) = star(O, 50, 5, 0.5, 0, do_action)
        acirc(args...; do_action = :stroke) = circle(Point(100, 100), 50, do_action)

        vid = Video(500, 500)
        back = Background(1:100, ground)
        star_obj = Object(1:100, astar)
        act!(star_obj, Action(morph_to(acirc; do_action = :fill)))

        l1 = @JLayer 20:60 100 100 Point(0, 0) begin
            obj = Object((args...) -> circle(O, 25, :fill))
            act!(obj, Action(1:20, appear(:fade)))
        end

        objects = vid.objects
        all_objects = [vid.objects..., Javis.flatten(vid.layers)...]
        frames = Javis.preprocess_frames!(all_objects)

        img = JavisNB._jupyter_viewer(vid, length(frames), objects, 30)
        @test img.output.val == Javis.get_javis_frame(vid, objects, 1, layers = [l1])

        txt = Interact.textbox(1:length(frames), typ = "Frame", value = 2)
        frm = Interact.slider(1:length(frames), label = "Frame", value = txt[] + 1)
        @test Javis.get_javis_frame(vid, objects, 2, layers = [l1]) ==
              Javis.get_javis_frame(vid, objects, txt[], layers = [l1])
        @test Javis.get_javis_frame(vid, objects, 3, layers = [l1]) ==
              Javis.get_javis_frame(vid, objects, frm[], layers = [l1])

        for i in 4:length(frames)
            output = Javis.get_javis_frame(vid, objects, i, layers = [l1])
            wdg = Widget(["frm" => frm, "txt" => txt], output = output)
            img = @layout! wdg vbox(hbox(:frm, :txt), output)
            @test img.output.val == output
        end
    end


    # @testset "test embed" begin
    # end
end