{
  lib,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  python3,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "rag_api";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "danny-avila";
    repo = "rag_api";
    rev = "v${version}";
    hash = "sha256-Qb1vYFe6iDi25UcBnZuySL04CsFaL1LFjstTrABHPmI=";
  };

  nativeBuildInputs = [
    makeWrapper
    python3
  ];

  propagatedBuildInputs = with python3.pkgs; [
    aiofiles
    asyncpg
    boto3
    cryptography
    docx2txt
    fastapi
    langchain
    langchain-aws
    langchain-community
    langchain-core
    langchain-huggingface
    langchain-mongodb
    langchain-ollama
    langchain-openai
    langchain-text-splitters
    markdown
    networkx
    opencv-python-headless
    openpyxl
    pandas
    pgvector
    psycopg2-binary
    pydantic
    pyjwt
    pymongo
    pypandoc
    pypdf
    python-dotenv
    python-magic
    python-multipart
    python-pptx
    rapidocr-onnxruntime
    sentence-transformers
    sqlalchemy
    unstructured
    uvicorn
    xlrd
  ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/python3.x/site-packages/rag_api
    mkdir -p $out/bin

    # Copy the Python source files
    cp -r * $out/lib/python3.x/site-packages/rag_api/

    # Create a wrapper script for the main entry point
    # (adjust based on how the application is meant to be run)
    makeWrapper ${python3}/bin/python $out/bin/rag-api \
      --add-flags "$out/lib/python3.x/site-packages/rag_api/main.py" \
      --prefix PYTHONPATH : "$out/lib/python3.x/site-packages:$PYTHONPATH"
  '';

  passthru.udpateScript = nix-update-script {};

  meta = with lib; {
    description = "RAG API implementation";
    homepage = "https://github.com/danny-avila/rag_api";
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = platforms.all;
  };
}
