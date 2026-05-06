import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProjectRepo {
  final String name;
  final String url;
  ProjectRepo({required this.name, required this.url});
}

class Project {
  final String id;
  final String name;
  final String tagline;
  final List<String> techStack;
  final String challenge;
  final String solution;
  final List<String> screenshots;
  final List<ProjectRepo> githubRepos;

  Project({
    required this.id,
    required this.name,
    required this.tagline,
    required this.techStack,
    required this.challenge,
    required this.solution,
    this.screenshots = const [],
    this.githubRepos = const [],
  });
}

final projectsProvider = Provider<List<Project>>((ref) {
  return [
    Project(
      id: 'ingredex',
      name: 'Ingredex',
      tagline: 'AI Food Ingredient Analyzer',
      techStack: [
        'Flutter',
        'FastAPI',
        'Groq LLaMA-3',
        'PostgreSQL',
        'Supabase',
        'Redis',
        'LangChain',
      ],
      challenge:
          'Consumers lack transparency on harmful ingredients and struggle with complex label reading.',
      solution:
          'Designed a food-ingredient REST API with CrewAI multi-agent pipeline (Groq LLaMA-3.3-70B) for automated analysis; integrated Groq Vision for OCR-based label extraction and Open Food Facts API for barcode lookup. \nImplemented Redis caching with deterministic ingredient hashing (12h TTL), JWT authentication with OTP, and async PostgreSQL via SQLAlchemy and Alembic for scan history persistence.',
      screenshots: [
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777905227/af6339c1-3a14-4695-87e1-951803571423.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777905250/6a543dff-e667-413d-99ad-c6506722eb37.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777905271/4fbdf7d6-c4d4-4b09-b0da-b9a6c794fe48.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777905291/d7b3aafd-fdd7-4491-9853-2e921eab0df5.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777905294/a57701aa-bb8b-43bd-8524-06a287332067.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777905319/1ce7d32c-269a-4070-8a4c-b28cf7f6b254.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777905329/7d968e82-069a-4f7d-8eff-ce78f068a92c.png',
      ],
      githubRepos: [
        ProjectRepo(
          name: 'Frontend',
          url: 'https://github.com/Op-Vision17/ingredex-frontend',
        ),
        ProjectRepo(
          name: 'Backend',
          url: 'https://github.com/Op-Vision17/ingredex-backend',
        ),
      ],

    ),
    Project(
      id: 'tensai',
      name: 'Tensai',
      tagline: 'AI Study Copilot with RAG',
      techStack: ['Flutter', 'FastAPI', 'Pinecone', 'LangGraph', 'Supabase'],
      challenge:
          'Students struggled to get trustworthy, context-aware answers from large study materials spread across PDFs, DOCX files, and notes, with poor source traceability and retrieval accuracy.',
      solution:
          'Engineered Tensai using Flutter, FastAPI, Pinecone, and LangGraph, delivering a RAG-powered study copilot that analyzes PDFs/notes to provide context-aware answers with cited sources, featuring interactive chat and secure study room collaboration.',
      screenshots: ['https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778003304/d6d310d5-45f0-427c-a0cf-7879041e146e.png',
      'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778003301/7878f570-fcb0-4166-a0b9-9028d5dfac8f.png',
      'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778003290/fb91d49e-f2e7-4ddd-a93e-9da1856d1178.png',
      ],
      githubRepos: [
        ProjectRepo(
          name: 'GitHub',
          url: 'https://github.com/Op-Vision17/Tensai',
        ),
      ],

    ),
    Project(
      id: 'baat-karo',
      name: 'Baat Karo',
      tagline: 'Real-time Communication Platform',
      techStack: ['Flutter', 'Node.js', 'Socket.io', 'Agora SDK', 'Firebase'],
      challenge:
          'Creating a real-time communication platform that could handle group messaging, live voice/video calls, offline notifications, and secure room-based collaboration with minimal latency.',
      solution:
          'Engineered Baatkaro using Flutter, Node.js, Socket.IO, MongoDB, and Agora, delivering real-time room-based chat, OTP authentication, HD audio/video calling, FCM-powered call/message notifications, and scalable JWT-secured socket communication.',
      screenshots: ['https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778003010/e3653ae6-74b9-4911-9ad7-9ca08c3708df.png'],
      githubRepos: [
        ProjectRepo(
          name: 'Frontend',
          url: 'https://github.com/Op-Vision17/baatkaro_frontend',
        ),
        ProjectRepo(
          name: 'Backend',
          url: 'https://github.com/Op-Vision17/Baat_karo_backend',
        ),
      ],

    ),
    Project(
      id: 'doctor-doom',
      name: 'Dr. Doom',
      tagline: 'AI-powered online meeting & collaboration platform',
      techStack: ['Flutter', 'Agora SDK', 'WebSocket', 'REST APIs', 'Riverpod'],
      challenge:
          'Online meetings often lack integrated collaboration tools and AI assistance, making it hard to manage tasks and meetings simultaneously.',
      solution:
          'Built Dr. Doom with Flutter and Agora for high-quality video meetings; integrated AI-driven task management and real-time collaborative whiteboards to enhance team productivity.',
      screenshots: [
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778002454/bdc7f2ba-d7cb-42c3-9c7b-866ddcdd8043.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778002483/f3c3b20d-40fc-44a6-8f8f-5810f4ac73e6.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778002500/fca29191-2840-4bea-948d-20cacb9530b1.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778002505/e25d0c06-6f08-44f3-b6d1-3f400927fd73.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778002512/1d30db6f-5574-4721-a7dc-a0380eb1a9f4.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778002532/ca61c543-cec9-4d31-a5b6-6e934dcd680d.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1778002541/ce0af6f8-b04e-46e7-86e1-6467935ba16a.png',
      ],
      githubRepos: [
        ProjectRepo(
          name: 'GitHub',
          url: 'https://github.com/Op-Vision17/dr.Doom_App',
        ),
      ],

    ),
    Project(
      id: 'documind',
      name: 'DocuMind',
      tagline: 'AI Study Copilot with RAG',
      techStack: ['ML', 'Node.js', 'MongoDB', 'Pinecone', 'RAG', 'REST APIs'],
      challenge:
          'Students struggled to extract trustworthy, context-aware answers from large study materials like PDFs, notes, and documents while maintaining source reliability and personalized learning workflows.',

      solution:
          'Engineered DocuMind using Flutter, Node.js, MongoDB, and Pinecone, delivering an AI-powered study copilot built on a Retrieval-Augmented Generation pipeline. Integrated document ingestion, semantic vector search, contextual AI chat, citation-backed responses, and persistent study sessions, while collaborating with the ML team responsible for the RAG and model infrastructure.',
      githubRepos: [
        ProjectRepo(
          name: 'ML',
          url: 'https://github.com/Op-Vision17/documind-ml',
        ),
        ProjectRepo(
          name: 'Backend',
          url: 'https://github.com/Op-Vision17/documind-backend',
        ),
      ],


    ),
    Project(
      id: 'mitra-ai',
      name: 'Mitra AI',
      tagline: 'Interactive 3D AI companion platform',
      techStack: [
        'Flutter',
        '3D Controller',
        'WebSocket',
        'REST APIs',
        'Riverpod',
        'AI Chat',
      ],
      challenge:
          'Creating an emotionally engaging AI companion experience that combines real-time conversational intelligence, customizable personalities, and smooth 3D character interactions without compromising UI performance.',
      solution:
          'Led Flutter development for Mitra AI, a collaborative college project featuring interactive 3D AI companions that users can talk to, personalize, and build dynamic conversations with. Engineered high-performance 3D model interactions, real-time chat interfaces, personality customization flows, and a visually immersive cross-platform UI, while backend and ML systems were developed by senior team members.',
      screenshots: [
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777965230/b004a2a7-c1ee-49cd-b21e-9fad48d85298.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777965222/b3c34541-d996-42c3-85ca-197063015f15.png',
        'https://res.cloudinary.com/ddtxcqyl0/image/upload/v1777965191/05a16d5a-04c8-4e1b-81f1-839eac561936.png',
      ],
      githubRepos: [
        ProjectRepo(
          name: 'GitHub',
          url: 'https://github.com/Op-Vision17/mitra-ai',
        ),
      ],

    ),
    Project(
      id: 'vision',
      name: 'Vision',
      tagline: 'QR-based event attendance management platform',
      techStack: ['Flutter', 'QR Scanner', 'REST APIs', 'Riverpod', 'Camera'],
      challenge:
          'Managing participant attendance during technical events was slow, error-prone, and difficult to scale with manual verification and paper-based tracking.',
      solution:
          'Built the Flutter client for Vision, a QR-powered attendance platform designed for technical club events. Engineered real-time QR scanning, camera integration, API-based attendance verification, and instant participant validation, enabling organizers to mark attendance accurately and efficiently at scale while collaborating with backend team members for server-side infrastructure.',
      
      githubRepos: [
        ProjectRepo(
          name: 'GitHub',
          url: 'https://github.com/Op-Vision17/attendance-app',
        ),
      ],

    ),
    Project(
      id: 'cineverse',
      name: 'CineVerse',
      tagline: 'Cinematic movie discovery experience',
      techStack: ['Flutter', 'TMDB API', 'REST APIs', 'Riverpod', 'Animations'],
      challenge:
          'Most movie discovery platforms feel cluttered and generic, making it difficult for users to explore trending content, detailed metadata, and personalized recommendations in an engaging way.',
      solution:
          'Built CineVerse, a visually immersive movie exploration app powered by the TMDB API. Engineered seamless REST API integration, dynamic content rendering, optimized image loading, and fluid animations to deliver trending movies, ratings, cast details, trailers, and rich cinematic browsing through a stunning cross-platform UI.',
      
      githubRepos: [
        ProjectRepo(
          name: 'GitHub',
          url: 'https://github.com/Op-Vision17/movies_app',
        ),
      ],

    ),
  ];
});

class SelectedProjectNotifier extends Notifier<Project?> {
  @override
  Project? build() => null;
  void setProject(Project project) => state = project;
}

final selectedProjectProvider =
    NotifierProvider<SelectedProjectNotifier, Project?>(
      () => SelectedProjectNotifier(),
    );
