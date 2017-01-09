class OpenMesh < Formula
  desc "Generic data structure to represent and manipulate polygonal meshes"
  homepage "https://openmesh.org/"
  url "https://www.openmesh.org/media/Releases/5.1/OpenMesh-5.1.tar.gz"
  sha256 "643262dec62d1c2527950286739613a5b8d450943c601ecc42a817738556e6f7"
  head "http://openmesh.org/svnrepo/OpenMesh/trunk/", :using => :svn

  bottle do
    cellar :any
    sha256 "696e707dbbc25c6b2b6504eb78336a8833f9d690bbb07f226d9529258fc984f2" => :sierra
    sha256 "80c3297bf3f7ab9c4b519dd9ae622ea5c87fb5afdebaabeb4b4c8d3149067016" => :el_capitan
    sha256 "e73e25f5adbb12bd20bf822e472a2a883f6d969c1cb340d76feb1a83fc4c02cf" => :yosemite
    sha256 "f55c01c2dbde31f9307530349141b33860f733bbe2836fc88d79536bcd3945d4" => :mavericks
  end

  depends_on "cmake" => :build

  patch do
    # Fixes missing include files in OpenMesh/Tools/Smoother during install
    url "https://graphics.rwth-aachen.de:9000/OpenMesh/OpenMesh/commit/c5cfef87427a793268f9e012856872bbed958d92.diff"
    sha256 "5180b3ea8e92b88e9212a4fcfc214666d3b2ca2133a95c2f6b0a44855a298c79"
  end

  def install
    mkdir "build" do
      system "cmake", "..", "-DBUILD_APPS=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
    #include <iostream>
    #include <OpenMesh/Core/IO/MeshIO.hh>
    #include <OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh>
    typedef OpenMesh::PolyMesh_ArrayKernelT<>  MyMesh;
    int main()
    {
        MyMesh mesh;
        MyMesh::VertexHandle vhandle[4];
        vhandle[0] = mesh.add_vertex(MyMesh::Point(-1, -1,  1));
        vhandle[1] = mesh.add_vertex(MyMesh::Point( 1, -1,  1));
        vhandle[2] = mesh.add_vertex(MyMesh::Point( 1,  1,  1));
        vhandle[3] = mesh.add_vertex(MyMesh::Point(-1,  1,  1));
        std::vector<MyMesh::VertexHandle>  face_vhandles;
        face_vhandles.clear();
        face_vhandles.push_back(vhandle[0]);
        face_vhandles.push_back(vhandle[1]);
        face_vhandles.push_back(vhandle[2]);
        face_vhandles.push_back(vhandle[3]);
        mesh.add_face(face_vhandles);
        try
        {
        if ( !OpenMesh::IO::write_mesh(mesh, "triangle.off") )
        {
            std::cerr << "Cannot write mesh to file 'triangle.off'" << std::endl;
            return 1;
        }
        }
        catch( std::exception& x )
        {
        std::cerr << x.what() << std::endl;
        return 1;
        }
        return 0;
    }

    EOS
    flags = %W[
      -I#{include}
      -L#{lib}
      -lOpenMeshCore
      -lOpenMeshTools
    ]
    system ENV.cxx, "test.cpp", "-o", "test", *flags
    system "./test"
  end
end
